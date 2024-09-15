module ApplicationHelper
  def hide_elements_on_pages?
    pages_to_hide_elements = [
      { controller: 'dashboards', action: 'index' },
      { controller: 'remind_mes', action: 'new' },
      { controller: 'remind_mes', action: 'create' },
      { controller: 'remind_mes', action: 'show' },
      { controller: 'remind_mes', action: 'edit' },
      { controller: 'remind_mes', action: 'update' },
      { controller: 'users/registrations', action: 'edit' },
      { controller: 'users/registrations', action: 'update' }
    ]

    pages_to_hide_elements.any? do |page|
      params[:controller] == page[:controller] && params[:action] == page[:action]
    end
  end

  def dashboard_link_path
    hide_elements_on_pages? ? dashboards_path : root_path
  end

  def default_email_from
    ApplicationMailer.default[:from]
  end
end