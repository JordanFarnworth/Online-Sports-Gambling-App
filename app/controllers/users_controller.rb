class UsersController < ApplicationController
  include Api::V1::User
  include PaginationHelper

  before_action :find_user, only: [:show, :edit, :update, :destroy]
  before_action :find_users, only: [:index]

  load_and_authorize_resource

  def index
    @user = User.new
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
    if @user.update user_params
      flash_message
      redirect_to :users
    else
      render 'show'
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
          render json: @user.errors, status: :bad_request
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
end
