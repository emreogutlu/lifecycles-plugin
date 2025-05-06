module Lifecycles
    module Services
      class SyncService
        def initialize(project)
          @project = project
        end
  
        def call 
          sync_issues
        end
  
        private
  
        def sync_issues
          @project.issues.find_each do |issue|
            open_lifecycles = Lifecycle.where(issue_id: issue.id, end: nil).to_a
            if open_lifecycles.empty?
              new_lifecycle = Lifecycle.create(
                issue_id: issue.id,
                user_id: issue.author_id,
                status_id: issue.status_id,
                start: issue.created_on
              )
              open_lifecycles.push(new_lifecycle)
            end
            sync_journal_details(issue, open_lifecycles)
          end
        end
  
        def sync_journal_details(issue, open_lifecycles)
          issue.journals.where(journalized_type: 'Issue').order(created_on: :asc).includes(:details).find_each do |journal|

            status_change = journal.details.find { |d| d.prop_key == 'status_id' } # find the journal detail of a status change
            next unless status_change
  
            already_exist = Lifecycle.exists?(journal_id: journal.id)
            next if already_exist

            last_lifecycle = open_lifecycles.first
            if last_lifecycle.nil?
              Rails.logger.error "[Lifecycles] Expected an open lifecycle for issue #{issue.id}, but none found!"
              return
            end

            now = journal.created_on

            #update the previous lifecycle
            last_lifecycle.update(
              end: now,
              duration: (now - last_lifecycle.start).to_i
            )
            open_lifecycles.shift # remove the updated lifecycle from the list (it's now closed)

            Lifecycle.create(
              issue_id: issue.id,
              journal_id: journal.id,
              user_id: journal.user_id,
              status_id: status_change.value,
              start: now
            )

          end
        end
      end
    end
end
