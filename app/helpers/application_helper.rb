module ApplicationHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def display_flash_messages
    content_tag(:div, class: 'flash-messages') do
      flash.map do |type, message|
        content_tag(:div, message, class: "flash #{type}")
      end.join.html_safe
    end
  end
end
