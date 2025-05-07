module Lifecycles
    module Patches
      module JournalDetailPatch
        def self.included(base)
          base.class_eval do
            after_create :start_new_stage
          end
        end
  
        def start_new_stage
          if !self.journal.issue.project.module_enabled?(:lifecycles)
            return
          end
          
          Stage.start_new_stage(self)
        end
      end
    end
end

JournalDetail.include Lifecycles::Patches::JournalDetailPatch
