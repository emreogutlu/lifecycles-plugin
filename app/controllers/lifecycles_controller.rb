class LifecyclesController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    load_filter_data
    filter_by
    calculate_total_time_spent
    apply_sorting
  end

  def popup
    @project = Project.find(params[:project_id])
    base_setup

    @issue_stages = cached_stages
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
    filter_data = Lifecycles::Services::StageFilterService.new(@project)
    @users = filter_data.users
    @issue_categories = filter_data.issue_categories
  end

  def base_setup
    @filters = {
      user_id: params[:user_id],
      category_id: params[:category_id]
    }.compact_blank
    @base_scope = Stage.filter_stages(@project.id, @filters)
  end

  def filter_by
    base_setup
    @stages = cached_stages
    
    grouped_counts = Stage.group_and_count_stages(@base_scope)
    @stages_by_user = grouped_counts[:by_user]
    @stages_by_category = grouped_counts[:by_category]
  end

  def apply_sorting
    @stages = Stage.sort_stages(@stages, params[:sort], params[:direction])
  end

  def cache_key
    [
      "stages_project_#{@project.id}",
      "version_#{cache_version}",
      "user_#{@filters[:user_id]}",
      "category_#{@filters[:category_id]}",
    ].compact.join("_")
  end

  def cache_version
    Rails.cache.fetch("stages_version_#{@project.id}") { Time.now.to_i }
  end

  def cached_stages
    Rails.cache.fetch(cache_key, expires_in: 5.minutes) { Stage.get_columns(@base_scope) }
  end

end
