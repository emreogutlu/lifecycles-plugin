module Lifecycles
    module Services
      class SyncService
        def initialize(project)
          @project = project
        end

        def call
          synchronize
        end

        def synchronize
          @project.issues.find_each do |issue|
            current_stage = Stage.where(issue_id: issue.id, end: nil).first
                
            if current_stage.nil?
              current_stage = Stage.start_new_lifecycle(issue)
            end
                
            sync_journal_details(issue, current_stage)
        
          end
        end
        
        private
        
        def sync_journal_details(issue, current_stage)
          issue.journals.where(journalized_type: 'Issue').order(created_on: :asc).includes(:details).find_each do |journal|
        
            journal_detail = journal.details.find { |d| d.prop_key == 'status_id' } # find the journal detail of a status change
            next unless journal_detail
        
            already_exist = Stage.exists?(journal_id: journal.id)
            next if already_exist
        
            current_stage = Stage.end_old_start_new_stage(issue, journal, journal_detail, current_stage)
        
          end
        end
      end
    end
end
