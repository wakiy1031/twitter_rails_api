# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[name email phone birthdate password password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[
                                        description place website user_name
                                        avatar_image header_image
                                      ])
  end
end
