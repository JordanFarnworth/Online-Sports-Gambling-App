module Api::V1::Role
  include Api::V1::Json

  def role_json(role, includes = {})
    attributes = %w(name permissions created_at updated_at)

    api_json(role, only: attributes)
  end

  def roles_json(roles, includes = {})
    roles.map { |r| role_json(r, includes) }
  end
end