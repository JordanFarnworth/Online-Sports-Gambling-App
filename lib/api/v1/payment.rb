module Api::V1::Payment
  include Api::V1::MonetaryTransaction
  include Api::V1::Json

  def payment_json(payment, includes = [])
    attributes = %w(user_id gateway uuid amount state braintree_transaction_id created_at updated_at)

    api_json(payment, only: attributes).tap do |hash|
      hash['transaction'] = monetary_transaction_json(payment.monetary_transaction) if includes.include? 'transaction'
    end
  end

  def payments_json(payments, includes = [])
    payments.map { |p| payment_json(p, includes) }
  end
end