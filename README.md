# Lifecycles Plugin for Redmine

This Redmine plugin displays the lifecycle of issues, composed of multiple issue status changes (stages). It can be toggled on or off for each project scope. For every issue, the plugin lists the time spent in each status, the issue’s category, and the user who changed the status, all displayed in a table. Results can be sorted by issue number or by time spent in each stage, and filtered by user or issue category. The total time spent, based on the applied filters, can also be displayed. When an issue is clicked, a pop-up bar graph visualizes its full lifecycle.

In order to install the plugin:
```
cd $REDMINE_ROOT
git clone https://github.com/emreogutlu/lifecycles-plugin.git plugins/lifecycles
bundle install
export RAILS_ENV="production"
bundle exec rake redmine:plugins:migrate
```

Restart your application server and lifecycles is ready to use.

Compatible with `Redmine 5.1.x`.

![Screenshot from 2025-05-13 02-07-32](https://github.com/user-attachments/assets/12278c4d-c496-42ac-abb0-969214c8d8fa)
