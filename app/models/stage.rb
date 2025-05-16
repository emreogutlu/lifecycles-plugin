class Stage < ActiveRecord::Base
    belongs_to :issue
    belongs_to :category, class_name: 'IssueCategory', foreign_key: 'category_id'
    belongs_to :status, class_name: 'IssueStatus', foreign_key: 'status_id'
    belongs_to :user

    after_commit :update_cache_version

    def self.start_new_lifecycle(issue_dto)
      return {
        issue_id: issue_dto.id,
        journal_id: nil,
        user_id: issue_dto.author_id, 
        status_id: 1, #status name: New
        category_id: issue_dto.category_id,
        start: issue_dto.created_on,
        end: nil,
        time_spent: nil
      }
    end

    def self.start_new_stage(journal_detail)
      prop_key = journal_detail.prop_key
      if prop_key != 'category_id' && prop_key != 'status_id'
        return
      end
  
      journal = journal_detail.journal
      issue = journal.issue
      current_stage = where(issue_id: issue.id, end: nil).first

      if prop_key == 'category_id'
        current_stage[:category_id] = journal_detail.value
      elsif prop_key == 'status_id'
        Stage.create(end_old_start_new_stage(issue, journal, current_stage, journal_detail))
      end
      current_stage.save
    end
  
    def self.end_old_start_new_stage(issue_dto, journal_dto, current_stage, journal_detail = nil)
      if current_stage.nil?
        Rails.logger.error "[Lifecycles] Expected an open stage for issue #{issue_dto.id}, but none found!"
        return
      end
  
      now = journal_dto.created_on
  
      #update the previous stage
      current_stage[:end] = now
      current_stage[:time_spent] = (now - current_stage[:start]).to_i
  
      new_stage = {
        issue_id: issue_dto.id,
        journal_id: journal_dto.id,
        user_id: journal_dto.user_id,
        status_id: journal_dto.respond_to?(:status_id) ? journal_dto.status_id : journal_detail&.value,
        category_id: issue_dto.category_id,
        start: now,
        end: nil,
        time_spent: nil
      }
      return new_stage
    end

    def self.filter_stages(project_id, filters)
      base_scope = Stage
        .joins(:issue, :status)
        .left_joins(:user, :category)
        .where(issues: { project_id: project_id })
        .where(filters)
    end

    def self.get_columns(base_scope)
      now = Time.now

      base_scope.select(
        'stages.*',
        'issues.subject AS issue_subject',
        'issue_statuses.name AS status_name',
        'issue_categories.name AS category_name',
        'users.firstname AS user_firstname',
        'users.lastname AS user_lastname',
        "ROUND((
          CASE 
            WHEN stages.time_spent IS NOT NULL THEN stages.time_spent
            ELSE TIMESTAMPDIFF(SECOND, stages.start, '#{now.to_s(:db)}')
          END
        ) / 3600.0, 2) AS calculated_time_spent"
      )
    end

    def self.group_and_count_stages(base_scope)
      {
        by_user: base_scope.group("users.firstname", "users.lastname")
                    .count
                    .transform_keys { |k| "#{k[0]} #{k[1]}" },

        by_category: base_scope.group("issue_categories.name").count
      }
    end

    def self.sort_stages(stages, sort_by, direction)
      direction = direction == 'asc' ? 'asc' : 'desc'
      
      return stages.order(time_spent: direction) if sort_by == 'time_spent'
      stages.order(issue_id: direction)
    end

    private 

    def update_cache_version
      Rails.cache.write("stages_version_#{issue.project_id}", Time.now.to_i)
    end
end
