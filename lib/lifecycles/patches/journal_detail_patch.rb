module Lifecycles
    module Patches
      module JournalDetailPatch
        def self.included(base)
          base.class_eval do
            after_create :update_lifecycle
          end
        end
  
        def update_lifecycle
            puts self.inspect
        end
      end
    end
end

JournalDetail.include Lifecycles::Patches::JournalDetailPatch