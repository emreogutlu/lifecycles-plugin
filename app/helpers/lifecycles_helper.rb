module LifecyclesHelper
    def toggle_direction(column)
      if column == 'issue_id'
        params[:direction] == 'asc' ? 'desc' : 'asc'
      else
        params[:direction] == 'desc' ? 'asc' : 'desc'
      end
    end

    def issue_link_or_placeholder(issue_id, issue_subject)
      if issue_id && issue_subject
        link_to(issue_subject, '#', class: 'issue-popup', data: { issue_id: issue_id })
      else
        '---'
      end
    end         
end
