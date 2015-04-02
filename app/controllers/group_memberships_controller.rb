class GroupMembershipsController < ApplicationController
  load_and_authorize_resource

  def create
    @group_membership = GroupMembership.find_or_initialize_by group_membership_params.slice(:user_id, :group_id)
    @group_membership.state = :active
    @group_membership.assign_attributes group_membership_params
    if @group_membership.save
      respond_to do |format|
        format.json do
          render json: @group_membership, status: :ok
        end
      end
    else
      respond_to do |format|
        format.json do
          render json: { errors: @group_membership.errors.full_messages }, status: :bad_request
        end
      end
    end
  end

  def update
    @group_membership = GroupMembership.find params[:id]
    if @group_membership.update group_membership_params
      respond_to do |format|
        format.json do
          render nothing: true, status: :no_content
        end
      end
    end
  end

  def destroy
    @group_membership = GroupMembership.find params[:id]
    @group_membership.destroy
    respond_to do |format|
      format.json do
        render nothing: true, status: :no_content
      end
    end
  end

  private
  def group_membership_params
    params.require(:group_membership).permit(:user_id, :group_id, :role)
  end
end
