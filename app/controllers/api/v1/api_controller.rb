class API::V1::ApiController < ApplicationController
  protect_from_forgery with: :null_session
  respond_to :json

protected

  def authenticate
    authenticate_or_request_with_http_token do |token, opts|
      @user = User.find_by(api_key: token)
    end
  end

end