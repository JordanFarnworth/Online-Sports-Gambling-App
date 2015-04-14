module Api::V1::MonetaryTransaction
  include Api::V1::Json

  def monetary_transaction_json(mt, includes = [])
    attributes = %w(user_id transaction_type amount state created_at updated_at)

    api_json(mt, only: attributes)
  end
end