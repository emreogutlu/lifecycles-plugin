module Lifecycles
    module Patches
      module IssuePatch
        def self.included(base)
          base.class_eval do
            after_create :start_new_lifecycle
          end
        end
  
        def start_new_lifecycle
          if !self.project.module_enabled?(:lifecycles) # if the plugin is disabled
            return
          end

          Stage.start_new_lifecycle(self)
        end
      end
    end
end

Issue.include Lifecycles::Patches::IssuePatch
