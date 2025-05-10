class LifecyclesController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    load_filter_data
    filter_by
    calculate_time_spent
    apply_sorting
  end

  private

  def calculate_time_spent
    now = Time.now
    @stage_spent_times = @stages.map do |stage|
      ((stage.time_spent || (now - stage.start)) / 3600.0).round(1)
    end
    @total_time_spent = @stage_spent_times.sum
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
    
    @stages = Stage
      .joins(:issue, :status, :user)
      .left_joins(:category)
      .where(issues: { project_id: @project.id })
      .where(filters)
      .select(
        'stages.*',
        'issues.subject AS issue_subject',
        'issue_statuses.name AS status_name',
        'issue_categories.name AS category_name',
        'users.firstname AS user_firstname',
        'users.lastname AS user_lastname'
      )
  end

  def apply_sorting
    sort = params[:sort]
    direction = params[:direction] == 'asc' ? 'asc' : 'desc'

    if sort == 'time_spent'
      @stages, @stage_spent_times = @stages.zip(@stage_spent_times).sort_by do |stage, stage_time|
        stage_time
      end.transpose
    else 
      @stages, @stage_spent_times = @stages.zip(@stage_spent_times).sort_by do |stage, stage_time|
        stage.issue_id
      end.transpose
    end

    if direction == 'desc'
      @stages.reverse! 
      @stage_spent_times.reverse!
    end
  end
end
