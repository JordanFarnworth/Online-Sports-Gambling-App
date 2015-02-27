class RoleMembershipsController < ApplicationController
  include Api::V1::RoleMembership

  before_action :find_role
  before_action :find_role_membership, only: [:destroy]
  load_and_authorize_resource

  def find_role
    @role = Role.active.find params[:role_id]
  end

  def find_role_membership
    @role_membership = @role.role_memberships.find params[:id]
  end

  def create
    @user = User.active.find params[:role_membership][:user_id]
    @role_membership = @role.add_user @user
    respond_to do |format|
      format.json do
        render json: role_membership_json(@role_membership), status: :ok
      end
    end
  end

  def destroy
    @role_membership.destroy
    respond_to do |format|
      format.json do
        render nothing: true, status: :no_content
      end
    end
  end

  private
  def role_membership_params
    params.require(:role_membership).permit(:user_id)
  end
end
