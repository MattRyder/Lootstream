class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  def twitch_auth(access_token)
    return @twitch_auth if @twitch_auth
    @twitch_auth = Twitch.new({access_token: access_token})
  end
  
  def twitch
    return @twitch if @twitch
    @twitch = Twitch.new({
      client_id: Rails.application.secrets.twitch_client_id,
      secret_key: Rails.application.secrets.twitch_secret_key,
      redirect_uri: root_url,
      scope: ["user_read", "channel_read"]
    })
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u|
      u.permit(:email, :access_token, :password, :password_confirmation)
    }
  end
end
