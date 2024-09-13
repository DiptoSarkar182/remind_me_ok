module ApplicationHelper
  def hide_elements_on_pages?
    pages_to_hide_elements = [
      { controller: 'dashboards', action: 'index' },
      { controller: 'remind_mes', action: 'new' },
      { controller: 'remind_mes', action: 'create' },
      { controller: 'remind_mes', action: 'edit' },
      { controller: 'remind_mes', action: 'update' },
      { controller: 'devise/registrations', action: 'edit' }
    ]

    pages_to_hide_elements.any? do |page|
      params[:controller] == page[:controller] && params[:action] == page[:action]
    end
  end

  def dashboard_link_path
    hide_elements_on_pages? ? dashboards_path : root_path
  end
end