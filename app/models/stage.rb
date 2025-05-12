class Stage < ActiveRecord::Base
    belongs_to :issue
    belongs_to :category, class_name: 'IssueCategory', foreign_key: 'category_id'
    belongs_to :status, class_name: 'IssueStatus', foreign_key: 'status_id'
    belongs_to :user

    def self.start_new_lifecycle(issue)
      create(
        issue_id: issue.id, 
        user_id: issue.author_id, 
        status_id: issue.status_id,
        category_id: issue.category_id,
        start: issue.created_on
      )
    end

    def self.start_new_stage(journal_detail)
      prop_key = journal_detail.prop_key
      if prop_key != 'category_id' && prop_key != 'status_id'
        return
      end
  
      journal = journal_detail.journal
      issue = journal.issue
      current_stage = where(issue_id: issue.id).where(end: nil).first

      if prop_key == 'category_id'
        current_stage.update(category_id: journal_detail.value)
      elsif prop_key == 'status_id'
        end_old_start_new_stage(issue, journal, journal_detail, current_stage)
      end
    end
  
    def self.end_old_start_new_stage(issue, journal, journal_detail, current_stage)
      if current_stage.nil?
        Rails.logger.error "[Lifecycles] Expected an open stage for issue #{issue.id}, but none found!"
        return
      end
  
      now = journal.created_on
  
      #update the previous stage
      current_stage.update(
        end: now,
        time_spent: (now - current_stage.start).to_i
      )
  
      new_stage = create(
        issue_id: issue.id,
        journal_id: journal.id,
        user_id: journal.user_id,
        status_id: journal_detail.value,
        category_id: issue.category_id,
        start: now
      )
      return new_stage
    end
end
