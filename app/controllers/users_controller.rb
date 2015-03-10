class UsersController < ApplicationController
  include Api::V1::User
  include PaginationHelper

  before_action :find_user, only: [:show, :edit, :update, :destroy, :group_memberships]
  before_action :find_users, only: [:index]
  before_action :find_groups, only: :show

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

  def update
    respond_to do |format|
      format.html do
        if @user.update user_params
          redirect_to users_path
        else
          render 'edit'
        end
      end
      format.json do
        if @user.update user_js_params
          render json: user_json(@user), status: :ok
        end
      end
    end
  end

  def find_groups
    @groups = @user.groups
  end

  def group_memberships
    groups = @user.group_memberships.includes(:group)
    respond_to do |format|
      format.json do
        render json: groups.map { |g| g.as_json.merge({ group: g.group }) }, status: :ok
      end
    end
  end

  def find_user
    @user = User.active.find params[:id]o
  end

  def find_users
    @users = User.active
  end

  def create
    @user = User.new user_params
    respond_to do |format|
      format.html do
        if @user.save
          redirect_to @user
        else
          render 'new'
        end
      end
      format.json do
        if @user.save
          render json: user_json(@user), status: :ok
        else
          render json: { errors: @user.errors }, status: :bad_request
        end
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
  def user_params
    params.require(:user).permit(:display_name, :username, :email, :password, :password_confirmation)
  end

  def user_js_params
    params.require(:user).permit(:display_name, :username, :email)
  end
end
