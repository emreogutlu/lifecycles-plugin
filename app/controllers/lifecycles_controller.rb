class LifecyclesController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    load_filter_data
    filter_by
    calculate_total_time_spent
    apply_sorting
  end

  def popup
    @issue_stages = @@static_stages
      .select { |stage| stage.issue_id == params[:issue_id].to_i }
      .group_by(&:status_name)
      .map { |status, stages| [status, stages.sum { |s| s.calculated_time_spent.to_f }] }
    
    @issue_subject = Issue.find_by(id: params[:issue_id])&.subject

    render partial: 'popup'
  end

  private

  def calculate_total_time_spent
    @total_time_spent = @stages.sum { |stage| stage.calculated_time_spent.to_f }
  end

  def load_filter_data
    @users = User.where(id: Stage.joins(:issue)
                                 .where(issues: { project_id: @project.id })
                                 .select(:user_id).distinct)

    @issue_categories = IssueCategory.where(id: Stage.joins(:issue)
                                 .where(issues: { project_id: @project.id })
                                 .select(:category_id).distinct)
  end

  def filter_by
    filters = {
      user_id: params[:user_id],
      category_id: params[:category_id]
    }.compact_blank
  
    base_scope = Stage
      .joins(:issue, :status, :user)
      .left_joins(:category)
      .where(issues: { project_id: @project.id })
      .where(filters)

    now = Time.now

    @stages = base_scope.select(
      'stages.*',
      'issues.subject AS issue_subject',
      'issue_statuses.name AS status_name',
      'issue_categories.name AS category_name',
      'users.firstname AS user_firstname',
      'users.lastname AS user_lastname',
      "ROUND((
        CASE 
          WHEN stages.time_spent IS NOT NULL THEN stages.time_spent
          ELSE TIMESTAMPDIFF(SECOND, stages.start, '#{now.to_s(:db)}')
        END
      ) / 3600.0, 2) AS calculated_time_spent"
    )

    @@static_stages = @stages
      
    @stages_by_user = base_scope
      .group("users.firstname", "users.lastname")
      .count
      .transform_keys { |k| "#{k[0]} #{k[1]}" }
  
    @stages_by_category = base_scope
      .group("issue_categories.name")
      .count
  end

  def apply_sorting
    sort = params[:sort]
    direction = params[:direction] == 'asc' ? 'asc' : 'desc'

    @stages = @stages.order(time_spent: direction) if sort == 'time_spent'
    @stages = @stages.order(issue_id: direction) unless sort == 'time_spent'
  end
end
