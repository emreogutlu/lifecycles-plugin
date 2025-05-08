Redmine::Plugin.register :lifecycles do
  name 'Lifecycles plugin'
  author 'emre'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/emreogutlu/lifecycles-plugin'
  author_url 'https://github.com/emreogutlu'

  project_module :lifecycles do
    permission :lifecycles, { lifecycles: [:index] }, public: true
  end
  menu :project_menu, :lifecycles, { controller: 'lifecycles', action: 'index' }, caption: 'Lifecycles', after: :activity, param: :project_id

end
