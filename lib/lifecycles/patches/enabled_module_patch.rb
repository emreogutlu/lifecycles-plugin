module Lifecycles
    module Patches
      module EnabledModulePatch
          def self.included(base) # :nodoc:
            base.class_eval do
              after_create :enable_lifecycles
            end
          end
  
          def enable_lifecycles
            if self.name == 'lifecycles'
              puts 'plugin enabled'
            end
          end
      end
    end
end
  
  EnabledModule.include Lifecycles::Patches::EnabledModulePatch
  