class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  # Handle authorization errors
  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: 'Access denied', message: exception.message }, status: :forbidden
  end
  
  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name role])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name role])
  end
end
