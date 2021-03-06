class Users::RegistrationsController < Devise::RegistrationsController

  def new
    resource = build_resource({})
    resource
  end

  def create
    super

    resource.access_token = session[:access_token]
    # setup the channel for this user, if not done so already
    user = twitch_auth(resource.access_token).your_user
    c_name = twitch.channel(user[:body]['name'])
    channel = Channel.find_or_create_by(name: c_name[:body]['name'])
    
    resource.update(channel: channel) if resource.channel.blank?
    resource.update(username: user[:body]["name"]) if resource.username.blank?
  end

end