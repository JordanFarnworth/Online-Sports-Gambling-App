module Api::V1::RoleMembership
  include Api::V1::User
  include Api::V1::Json

  def role_membership_json(role_membership, includes = {})
    attributes = %w(id role_id user_id created_at updated_at)

    api_json(role_membership, only: attributes).tap do |hash|
      hash[:user] = user_json(role_membership.user)
    end
  end

  def role_memberships_json(role_memberships, includes = {})
    role_memberships.map { |rm| role_membership_json(rm, includes) }
  end
end