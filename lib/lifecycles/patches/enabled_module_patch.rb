module Lifecycles
    module Patches
      module EnabledModulePatch
        def self.included(base) # :nodoc:
          base.class_eval do
            after_create :synchronize_lifecycles
          end
        end
  
        def synchronize_lifecycles
          if self.name != 'lifecycles'
            return
          end

          Lifecycles::Services::SyncService.new(self.project).call
        end
      end
    end
end
  
EnabledModule.include Lifecycles::Patches::EnabledModulePatch
  