module Lifecycles
    module Patches
      module IssuePatch
        def self.included(base)
          base.class_eval do
            after_create :init_lifecycle
          end
        end
  
        def init_lifecycle
          if !self.project.module_enabled?(:lifecycles) # if the plugin is disabled
            return
          end

          Lifecycle.create(
            issue_id: self.id, 
            user_id: self.author_id, 
            status_id: self.status_id, 
            start: Time.now
          )
        end
      end
    end
end

Issue.include Lifecycles::Patches::IssuePatch
