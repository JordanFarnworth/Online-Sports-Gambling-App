class UsersController < ApplicationController
  include Api::V1::User
  include PaginationHelper

  before_action :find_user, only: [:show, :edit, :update, :destroy]
  before_action :find_users, only: [:index]

  load_and_authorize_resource

  def index
    @users = User.active
    if params[:search_term]
      t = params[:search_term]
      @users = @users.where('username LIKE ? OR display_name LIKE ? OR email LIKE ?', "%#{t}%", "%#{t}%", "%#{t}%")
    end
    respond_to do |format|
      format.json do
        render json: pagination_json(@users, :users_json), status: :ok
      end
      format.html do
        @users = @users.paginate pagination_help
      end
    end
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

  def group_memberships
    groups = @user.group_memberships.includes(:group)
    respond_to do |format|
      format.json do
        render json: groups.map { |g| g.as_json.merge({ group: g.group }) }, status: :ok
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html do
        flash[:success] = 'User deleted!'
        redirect_to :users
      end
      format.json do
        render nothing: true, status: :no_content
      end
    end
  end

  private
  def flash_message(method = 'update')
    flash[:success] = "New User <a class=\"link-color\" href=#{user_path(@user)}>#{@user.display_name}</a> #{method == 'update' ? 'updated' : 'created'}!".html_safe
  end

  def user_params
    params.require(:user).permit(:display_name, :username, :email, :password, :password_confirmation)
  end
end
