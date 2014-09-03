class RegistrationsController < Devise::RegistrationsController

  def new
    resource = build_resource({})

    if params[:code]
      data = twitch.auth(params[:code])
      resource.access_token = data[:body]["access_token"]
      user_data = twitch_auth(resource.access_token).getYourUser
      resource.email = user_data[:body]['email']
    end

    resource
  end

end