module Api::V1::GroupMembership
  include Api::V1::Json
  include Api::V1::Group

  def group_membership_json(group_membership, includes = [])
    attributes = %w(id user_id group_id created_at updated_at role)

    api_json(group_membership, only: attributes).tap do |hash|
      hash['group'] = group_json(group_membership.group) if includes.include?('group')
    end
  end

  def group_memberships_json(group_memberships, includes = [])
    group_memberships.map { |g| group_membership_json(g, includes) }
  end
end