module Api::V1::Group
  include Api::V1::Json

  def group_json(group, includes = [])
    attributes = %w(id name settings created_at updated_at)

    api_json(group, only: attributes)
  end

  def groups_json(groups, includes = [])
    groups.map { |g| group_json(g, includes) }
  end
end