class GroupsController < ApplicationController
  before_action :find_group, only: [:users]
  before_action :find_groups, only: [:index, :show, :users]

  def find_groups
    @groups = Group.active
  end

  def find_group
    @group = Group.active.find(params[:id] || params[:group_id])
  end

  def index
    respond_to do |format|
      format.json do
        @groups = @groups
        render json: @groups, status: :ok
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

  def users
    authorize! :read, @group
    @users = @group.users.active
    respond_to do |format|
      format.json do
        render json: @users, status: :ok
      end
      format.html
    end
  end
end

