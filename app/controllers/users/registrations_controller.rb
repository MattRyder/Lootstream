class Users::RegistrationsController < Devise::RegistrationsController

  def new
    resource = build_resource({})
    resource
  end

  def create
    super

    resource.access_token = session[:access_token]
    # setup the channel for this user, if not done so already
    user = twitch_auth(resource.access_token).getYourUser()
    c_name = twitch.getChannel(user[:body]['name'])
    channel = Channel.find_or_create_by(name: c_name[:body]['name'])
    
    if resource.channel.blank?
      resource.update(channel: channel)
    end
  end

end