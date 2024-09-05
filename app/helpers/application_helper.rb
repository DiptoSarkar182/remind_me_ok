module ApplicationHelper
  def hide_elements_on_pages?
    pages_to_hide_elements = [dashboards_path, new_remind_me_path]
    pages_to_hide_elements << edit_remind_me_path(@remind_me) if defined?(@remind_me) && @remind_me&.persisted?
    pages_to_hide_elements.any? { |path| current_page?(path) }
  end
end
