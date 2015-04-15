class GroupsController < ApplicationController

  include PaginationHelper
  include Api::V1::Group
  include Api::V1::User
  include Api::V1::GroupMembership

  before_action :find_group, only: [:users, :show, :edit, :update, :destroy, :potential_applicants]
  before_action :find_groups, only: [:index]

  load_and_authorize_resource

  def find_groups
    @groups = Group.active
  end

  def find_group
    @group = Group.active.find(params[:id] || params[:group_id])
  end

  def index
    if params[:search_term]
      t = params[:search_term]
      @public_groups = @groups.where('name LIKE ?', "%#{t}%")
    end
    respond_to do |format|
      format.json do
        render json: pagination_json(@groups, :groups_json), status: :ok
      end
      format.html
    end
  end

  def show
    respond_to do |format|
      format.json do
        render json: @group, status: :ok
      end
      format.html
    end
  end

  def create
    respond_to do |format|
      format.html do
        if @group.save
          flash[:success] = 'Group created!'
          redirect_to @group
        else
          render 'new'
        end
      end
      format.json do
        if @group.save
          render json: @group, status: :ok
        else
          render json: { errors: @group.errors.full_messages }, status: :bad_request
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.html do
        if @group.update group_params
          redirect_to @group
        else
          render 'edit'
        end
      end
      format.json do
        if @group.update group_params
          render json: @group, status: :ok
        else
          render json: { errors: @group.errors.full_messages }, status: :bad_request
        end
      end
    end
  end

  def destroy
    @group.destroy
    respond_to do |format|
      format.html do
        redirect_to groups_path
      end
      format.json do
        render nothing: true, status: :no_content
      end
    end
  end

  def potential_applicants
    @available_users = User.where.not(id: @group.users.pluck(:id))
    if params[:search_term]
      t = params[:search_term]
      @available_users = @available_users.where('username LIKE ? OR display_name LIKE ? OR email LIKE ?', "%#{t}%", "%#{t}%", "%#{t}%")
    end
    respond_to do |format|
      format.json do
        render json: pagination_json(@available_users, :users_json), status: :ok
      end
    end
  end



  def users
    includes = params[:include] || []
    @gms = @group.group_memberships
    respond_to do |format|
      format.json do
        @gms = @gms.includes(:user) if includes.include?('user')
        @gms = @gms.includes(:group) if includes.include?('group')
        render json: pagination_json(@gms, :group_memberships_json, includes), status: :ok
      end
      format.html
    end
  end

  private
  def group_params
    params.require(:group).permit(:name, settings: [:max_users, :description, :availability, :lobbies])
  end
end

