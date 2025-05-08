module LifecyclesHelper
    def toggle_direction(column)
      if column == 'issue_id'
        params[:direction] == 'asc' ? 'desc' : 'asc'
      else
        params[:direction] == 'desc' ? 'asc' : 'desc'
      end
    end
end
