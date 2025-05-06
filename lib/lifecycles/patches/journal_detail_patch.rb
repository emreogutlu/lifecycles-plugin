module Lifecycles
    module Patches
      module JournalDetailPatch
        def self.included(base)
          base.class_eval do
            after_create :create_new_update_old_lifecycle
          end
        end
  
        def create_new_update_old_lifecycle
          journal = self.journal
          issue = journal.issue

          if !issue.project.module_enabled?(:lifecycles)
            return
          end

          if self.prop_key != 'status_id' # the update is not about a status
            return
          end

          last_lifecycle = Lifecycle.where(issue_id: issue.id).where(end: nil).first
          if last_lifecycle.nil?
            Rails.logger.error "[Lifecycles] Expected an open lifecycle for issue #{issue.id}, but none found!"
            return
          end

          now = journal.created_at

          #update the previous lifecycle
          last_lifecycle.update(
            end: now,
            duration: (now - last_lifecycle.start).to_i
          )

          Lifecycle.create(
            issue_id: issue.id,
            journal_id: self.journal_id,
            user_id: journal.user_id,
            status_id: self.value, # the new status_id
            start: now
          )
        end
      end
    end
end

JournalDetail.include Lifecycles::Patches::JournalDetailPatch
