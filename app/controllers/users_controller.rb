class UsersController < ApplicationController
  include Api::V1::User
  include PaginationHelper
  skip_authorization_check only: [:stop_masquerading]
  skip_load_and_authorize_resource only: [:stop_masquerading]

  before_action :find_user, only: [:show, :edit, :update, :destroy, :masquerade]
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

  def update
    respond_to do |format|
      format.html do
        if @user.update user_params
          redirect_to users_path
        else
          render 'edit'
        end
      end
    end
  end

  def find_user
    @user = User.active.find params[:user_id] || params[:id]
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

  def masquerade
    authorize! :masquerade, @user
    cookie_type['sports_b_masquerade_user'] = @user.id
    redirect_to request.referer || :root
  end

  def stop_masquerading
    cookie_type.delete 'sports_b_masquerade_user'
    redirect_to request.referer || :root
  end

  private
  def user_params
    params.require(:user).permit(:display_name, :username, :email, :password, :password_confirmation)
  end
end
