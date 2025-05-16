module Lifecycles
    module Services
      class StageFilterService
        def initialize(project)
            @project = project
        end

        def users
            User.where(id: base_scope.select(:user_id).distinct)
        end

        def issue_categories
            IssueCategory.where(id: base_scope.select(:category_id).distinct)
        end

        private

        def base_scope
            Stage.joins(:issue).where(issues: { project_id: @project.id })
        end
      end
    end
end
