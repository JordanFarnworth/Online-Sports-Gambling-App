class RolesController < ApplicationController
  include PaginationHelper
  include Api::V1::User
  include Api::V1::Role

  before_action :find_role, only: [:show, :edit, :update, :destroy, :users]
  before_action :find_roles, only: [:index, :show]
  load_and_authorize_resource

  def find_role
    @role = Role.active.find params[:id] || params[:role_id]
  end

  def find_roles
    @roles = Role.active
  end

  def index
    respond_to do |format|
      format.json do
        render json: pagination_json(@roles, :roles_json), status: :ok
      end
      format.html
    end
  end

  def create
    update_permissions
    respond_to do |format|
      format.html do
        if @role.save
          flash[:success] = 'Role created!'
          redirect_to @role
        else
          render 'new'
        end
      end
      format.json do
        if @role.save
          render json: role_json(@role), status: :ok
        else
          render json: { errors: @role.errors.full_messages }, status: :bad_request
        end
      end
    end
  end

  def update
    update_permissions
    respond_to do |format|
      format.html do
        if @role.update role_params
          flash[:success] = 'Role updated!'
          redirect_to @role
        else
          render 'edit'
        end
      end
      format.json do
        if @role.update role_params
          render json: role_json(@role), status: :ok
        else
          render json: { errors: @role.errors.full_messages }, status: :bad_request
        end
      end
    end
  end

  def update_permissions
    @role.permissions.clear
    return unless params[:permissions]
    Role::PERMISSION_TYPES.each do |p|
      @role.permissions[p[:name]] = params[:permissions][p[:name]]
    end
  end

  def destroy
    @role.destroy
    respond_to do |format|
      format.html do
        flash[:success] = 'Role deleted!'
        redirect_to roles_path
      end
      format.json do
        render nothing: true, status: :no_content
      end
    end
  end

  def users
    authorize! :read, @role
    @users = @role.users.active
    respond_to do |format|
      format.json do
        render json: pagination_json(@users, :users_json), status: :ok
      end
      format.html do
        @users = @users.paginate pagination_help
      end
    end
  end

  private
  def role_params
    params.require(:role).permit(:name)
  end
end
