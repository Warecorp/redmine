namespace :migrate_to_agile do

  def migrate_to_agile rules, clazz, tables
    ActiveRecord::Base.transaction do
      rules.each do |old_name, new_name|
        old = clazz.find_by_name old_name
        new_obj = clazz.find_by_name new_name
        tables.each do |table, column_names|
          column_names.each do |column_name|
            ActiveRecord::Base.connection.execute %s{
              update #{table} set
              #{column_name} = #{new_obj.id}
              where #{column_name} = #{old.id}
            }
          end
        end
      end
    end
  end

  task migrate: :environment do
    [ 'migrate_tasks', 'migrate_issue_statuses',
      'migrate_activities', 'migrate_roles' ].each do |task|
      Rake::Task["migrate_to_agile:#{task}"].execute
    end
  end

  task migrate_tasks: :environment do
    trackers = {
      'Bug' => 'Bug',
      'Requirement' => 'Story',
      'CR' => 'Story',
      'Task' => 'Task',
      'Build Installation' => 'Task',
      'Ticket' => 'Ticket'
    }

    all_trackers_exists = (trackers.keys + trackers.values).all? do |name|
      Tracker.where(name: name).present?
    end

    unless all_trackers_exists
      raise 'Create all trackers or change migration'
    end

    tracker_tables = {
      'code_review_project_settings' => ['tracker_id'],
      'custom_fields_trackers' => ['tracker_id'],
      'issues' => ['tracker_id'],
      'projects_trackers' => ['tracker_id'],
      'workflows' => ['tracker_id']
    }

    migrate_to_agile trackers, Tracker, tracker_tables
  end

  task migrate_issue_statuses: :environment do
    issue_statuses = {
      'New' => 'New',
      'Ready for programming' => 'New',
      'Rejected' => 'Done',
      'In progress' => 'In Progress',
      'On Hold' => 'New',
      'Declined' => 'Done',
      'Ready for Testing' => 'In QA',
      'Fixed' => 'In QA',
      'Ready for Client' => 'In UAT',
      'Verified' => 'In UAT',
      'Reopened' => 'New',
      'Closed' => 'Done',
      'Completed' => 'Done',
      'Future Req' => 'New',
      'Need More Info' => 'New',
      'Estimate Needed' => 'New'
    }

    all_issue_statuses_exists = (issue_statuses.keys + issue_statuses.values).all? do |name|
      IssueStatus.where(name: name).present?
    end

    unless all_issue_statuses_exists
      raise 'Create all issue statuses or change migration'
    end

    issue_statuses_tables = {
      'chart_issue_statuses' => ['status_id'],
      'issues' => ['status_id'],
      'trackers' => ['default_status_id'],
      'workflows' => ['old_status_id', 'new_status_id']
    }

    migrate_to_agile issue_statuses, IssueStatus, issue_statuses_tables
  end

  task migrate_activities: :environment do
    time_entry_activities = {
      'Consulting' => 'DOC',
      'UEX: IA' => 'BA',
      'UEX: BA' => 'BA',
      'UEX: design' => 'BA',
      'UEX: html' => 'FE',
      'DEV: coding' => 'BE',
      'DEV: bugfixing' => 'BE',
      'DEV: code review' => 'BE',
      'DEV: architecture' => 'BE',
      'QA: test plan/cases' => 'QA',
      'QA: smoke test' => 'QA',
      'QA: detailed test' => 'QA',
      'QA: reviews' => 'QA',
      'PM: USA' => 'PM',
      'PM: OPM' => 'PM',
      'IT: setup' => 'IT',
      'IT: hosting' => 'IT',
      'IT: architecture' => 'IT',
      'IT: research' => 'IT',
      'ORG: out of office' => 'OOO',
      'ORG: administrative' => 'MEET',
      'ORG: education' => 'EDU',
      'ORG: meetings' => 'MEET'
    }

    all_time_entry_activities_exists = (time_entry_activities.keys + time_entry_activities.values).all? do |name|
      TimeEntryActivity.where(name: name).present?
    end

    unless all_time_entry_activities_exists
      raise 'Create all time entry activities or change migration'
    end

    time_entry_activities_tables = {
      'chart_time_entries' => ['activity_id'],
      'time_entries' => ['activity_id']
    }

    migrate_to_agile time_entry_activities, TimeEntryActivity, time_entry_activities_tables
  end

  task migrate_roles: :environment do
    roles = {
      'Executive Sponsor' => 'Manager',
      'Executive Sponsor - Backup' => 'Manager',
      'Project Manager' => 'Project Manager',
      'Offshore Project Manager' => 'Project Manager',
      'Manager' => 'Manager',
      'Architect' => 'Developer',
      'Developer or Contractor' => 'Developer',
      'BA-IA' => 'BA',
      'Test Lead' => 'QA',
      'Tester' => 'QA',
      'Build Manager' => 'DevOps',
      'Client - Watch Only' => 'Watcher',
      'Client - can make updates' => 'Client',
      'Employee' => 'Watcher',
      'Reviewer' => 'Watcher',
      'CPP Client' => 'Watcher',
      'Salesperson' => 'Account'
    }

    all_roles_exists = (roles.keys + roles.values).all? do |name|
      Role.where(name: name).present?
    end

    unless all_roles_exists
      raise 'Create roles or change migration'
    end


    roles_tables = {
      'workflows' => ['role_id'],
      'custom_fields_roles' => ['role_id'],
      'member_roles' => ['role_id'],
      'queries_roles' => ['role_id']
    }

    migrate_to_agile roles, Role, roles_tables
  end

end
