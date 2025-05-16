module Lifecycles
    module Services
      class SyncService
        IssueDTO = Struct.new(:id, :author_id, :category_id, :created_on, keyword_init: true)
        JournalDTO = Struct.new(:issue_id, :id, :user_id, :status_id, :created_on, keyword_init: true)

        def initialize(project)
          @project = project
        end

        def call
          synchronize
          Stage.insert_all(@stages_to_create) unless @stages_to_create.empty?
        end

        def synchronize
          @stages_to_create = []

          select_issues
          select_journals_by_issue_ids
          select_unsychronized_stages

          @issue_dtos.each do |issue_dto|
            current_stage = @unsychronized_stages[issue_dto.id]
            save = false

            if current_stage.nil?
              current_stage = Stage.start_new_lifecycle(issue_dto)
              @stages_to_create << current_stage
            else
              save = true
            end

            sync_journal_details(issue_dto, current_stage, save)
          end
        end
        
        private
        
        def sync_journal_details(issue_dto, current_stage, save)
          journals_by_issue_id = @journals_grouped_by_issue_ids[issue_dto.id] || []

          journals_by_issue_id.each do |journal_dto|
            next if @synchronized_journals.include?(journal_dto.id)

            new_stage = Stage.end_old_start_new_stage(issue_dto, journal_dto, current_stage)
            if save
              current_stage.save
              save = false
            end

            @stages_to_create << new_stage
            current_stage = new_stage
          end

        end

        def select_issues
          @issue_dtos = @project.issues.pluck(:id, :author_id, :category_id, :created_on).map do |id, author_id, category_id, created_on|
            IssueDTO.new(id: id, author_id: author_id, category_id: category_id, created_on: created_on)
          end
        end

        def select_journals_by_issue_ids
          journals_with_details = Journal
            .joins(:details)
            .where(journalized_type: 'Issue', journalized_id: @issue_dtos.map { |issue_dto| issue_dto.id })
            .where(journal_details: { prop_key: 'status_id' })
            .order(created_on: :asc)
            .pluck(
              'journals.journalized_id',
              'journals.id',
              'journals.user_id',
              'journal_details.value',
              'journals.created_on'
            )

          journal_dtos = journals_with_details.map do |issue_id, journal_id, user_id, status_id, created_on|
            JournalDTO.new(
              issue_id: issue_id,
              id: journal_id,
              user_id: user_id,
              status_id: status_id,
              created_on: created_on
            )
          end
          
          @journals_grouped_by_issue_ids = journal_dtos.group_by(&:issue_id)
          
          @synchronized_journals = Stage.where(journal_id: journal_dtos.map(&:id))
            .pluck(:journal_id)
            .to_set
        end

        def select_unsychronized_stages
          @unsychronized_stages = Stage.where(issue_id: @issue_dtos.map(&:id), end: nil)
            .index_by(&:issue_id)
        end

      end
    end
end
