class UsersController < ApplicationController

  before_action :find_user, only: [:assigned_tickets, :requested_tickets, :group_memberships, :masquerade, :show, :edit, :update, :destroy]
  before_action :find_users, only: [:index]


  def index
    @users = User.all
  end

  def find_user
    @user = User.active.find params[:id]
  end

  def find_users
    @users = User.active
  end

  def create
    @user = User.new user_params
    if @user.save
      redirect_to @user
    else
      render 'new'
    end
  end

  private
  def flash_message(method = 'update')
    flash[:success] = "New User <a class=\"link-color\" href=#{user_path(@user)}>#{@user.display_name}</a> #{method == 'update' ? 'updated' : 'created'}!".html_safe
  end

  def user_params
    params.require(:user).permit(:display_name, :username, :email, :password, :password_confirmation, :image)
  end
end
