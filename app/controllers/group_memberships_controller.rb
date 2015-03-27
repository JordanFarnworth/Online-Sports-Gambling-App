class GroupMembershipsController < ApplicationController
  load_and_authorize_resource

  def create
    @group_membership = GroupMembership.new group_membership_params
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



  private
  def group_membership_params
    params.require(:group_membership).permit(:user_id, :group_id)
  end
end
