# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_update_path_for(resource)
    dashboards_path
  end
end