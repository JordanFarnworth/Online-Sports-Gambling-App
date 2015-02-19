class LoginController < ApplicationController
  def index

  end

  def verify
    user = User.active.find_by(username: params[:username]).try(:authenticate, params[:password])
    unless user
      flash[:error] = 'Incorrect username or password'
      render 'index'
    else
      key = SecurityHelper.get_session_key
      user.login_sessions.create! key: SecurityHelper.sha_hash(key), expires_at: 1.week.from_now
      cookies.encrypted[:sports_b_key] = {
        value: key,
        expires: 1.week.from_now
      }
      flash.clear
      redirect_to :root
    end
  end

  def logout
    ls = LoginSession.find_by key: SecurityHelper.sha_hash(cookies.encrypted[:sports_b_key])
    ls.destroy if ls
    cookies.delete :sports_b_key
    flash[:notice] = 'You have been logged out.'
    redirect_to :root
  end
end