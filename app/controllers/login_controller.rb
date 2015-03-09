class LoginController < ApplicationController
  skip_authorization_check

  def verify
    user = User.active.find_by(username: params[:username]).try(:authenticate, params[:password])
    unless user
      flash[:error] = 'Incorrect username or password'
      render 'index'
    else
      key = SecurityHelper.get_session_key
      user.login_sessions.create! key: SecurityHelper.sha_hash(key), expires_at: 1.week.from_now
      cookie_type[:sports_b_key] = {
        value: key,
        expires: 1.week.from_now
      }
      flash.clear
      redirect_to :root
    end
  end

  def logout
    ls = LoginSession.find_by key: SecurityHelper.sha_hash(cookie_type[:sports_b_key])
    ls.destroy if ls
    cookies.delete :sports_b_key
    cookies.delete 'sports_b_masquerade_user'
    flash[:notice] = 'You have been logged out.'
    redirect_to :root
  end
end