module Lifecycles
    module Patches
      module IssuePatch
        def self.included(base)
          base.class_eval do
            after_create :start_lifecycle
          end
        end
  
        def start_lifecycle
            puts "New Issue created with ID: #{self.id}"
        end
      end
    end
end

Issue.include Lifecycles::Patches::IssuePatch