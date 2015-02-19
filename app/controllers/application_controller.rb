class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_current_user

  def set_current_user
    if cookies[:sports_b_key]
      @current_user = User.active.joins("LEFT JOIN login_sessions AS l on l.user_id = users.id").where("l.key = ? AND l.expires_at > ?", SecurityHelper.sha_hash(cookies.encrypted[:sports_b_key]), Time.now).first
    end
  end

  def current_user
    @current_user
  end

  def logged_in?
    !!@current_user
  end

  def render_unauthorized
    respond_to do |format|
      format.html do
        flash[:error] = 'Oops, you\'re not authorized to perform that action'
        redirect_to :root
      end
      format.json do
        render json: { 'message' => 'Oops, looks like you\'re not authorized to perform that action' }, status: 401
      end
    end
  end


  private :set_current_user
  helper_method :logged_in?
end
