class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token, if: 'api_request?'

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        redirect_to root_url, :alert => exception.message
      end
      format.json do
        render json: { message: exception.message }, status: 401
      end
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json do
        render json: { message: 'not found' }, status: :not_found
      end
    end
  end

  def api_request?
    request.format.symbol == :json
  end

  before_action :set_current_user
  before_action :log_page_view

  def set_current_user
    if api_request?
      if request.headers['Authorization'] && request.headers['Authorization'].match(/Bearer (.+)/)
        token = request.headers['Authorization'].match(/Bearer (.+)/)[1]
      end
      token ||= params[:access_token]
      @current_user ||= User.active.joins("LEFT JOIN api_keys AS a on a.user_id = users.id").where("a.key = ? AND a.expires_at > ?", SecurityHelper.sha_hash(token), Time.now).first if token
    end
    if cookie_type[:sports_b_key]
      @current_user ||= User.active.joins("LEFT JOIN login_sessions AS l on l.user_id = users.id").where("l.key = ? AND l.expires_at > ?", SecurityHelper.sha_hash(cookie_type[:sports_b_key]), Time.now).first
    end
    @real_user = @current_user
    if logged_in? && (cookie_type['sports_b_masquerade_user'] || params['as_user_id'])
      masq_user = User.active.find_by_id cookie_type['sports_b_masquerade_user'] || params['as_user_id']
      if can?(:masquerade, masq_user)
        @current_user = masq_user
        @current_ability = Ability.new(@current_user)
      end
    end
  end

  # :nocov:
  def masquerading?
    @real_user != @current_user
  end
  # :nocov:

  def current_user
    @current_user
  end

  def logged_in?
    !!@current_user
  end

  def cookie_type
    Rails.env == 'production' ? cookies.encrypted : cookies
  end

  def log_page_view
    f = ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
    p = params.clone
    p.delete :action
    p.delete :controller
    p.delete :authenticity_token
    p = PageView.strip_files(p)
    PageView.create({
      user: @current_user,
      real_user: @real_user,
      path: request.path_info,
      ip_address: request.remote_ip,
      http_method: request.method,
      user_agent: request.user_agent,
      parameters: f.filter(p),
      referrer: request.referer,
      request_format: request.format.symbol.to_s,
      controller: params[:controller],
      action: params[:action]
    })
  end

  private :set_current_user
  helper_method :logged_in?
  helper_method :masquerading?
end
