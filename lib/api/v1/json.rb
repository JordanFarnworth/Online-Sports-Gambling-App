module Api::V1::Json

  def api_json(obj, opts = {})
    json = obj.as_json(opts)

    if block_given?
      dynamic_attributes = OpenStruct.new
      yield dynamic_attributes, obj
      json.merge!(dynamic_attributes.marshal_dump)
    end

    json
  end
end