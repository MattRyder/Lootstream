module ApplicationHelper

  def resource_name
    :user
  end

  def resource_name
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def channel_view?
    current_page?(controller: "/channels", action: "show")
  end
    
end
