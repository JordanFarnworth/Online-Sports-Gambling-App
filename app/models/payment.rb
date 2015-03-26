class Payment < ActiveRecord::Base
  belongs_to :monetary_transaction
  belongs_to :user

  VALID_GATEWAYS = [
    'paypal'
  ]

  validates_presence_of :user
  validates_presence_of :uuid
  validates_inclusion_of :gateway, in: VALID_GATEWAYS
  validates_inclusion_of :state, in: %w(initiated processed failed)
  validates_numericality_of :amount, greater_than: 0.0, less_than: 10000.0, allow_nil: true

  serialize :parameters, Hash

  before_validation do
    self.uuid ||= SecureRandom.uuid
    self.state ||= :initiated
  end

  after_save do
    if self.state == 'processed' && self.monetary_transaction.nil?
      t = MonetaryTransaction.create user: self.user, amount: self.amount, transaction_type: 'payment'
      self.update monetary_transaction: t
    end
  end

  def gateway_url(return_path = '')
    raise 'must be saved before serving gateway details' if self.new_record?
    paypal_url(return_path) if gateway == 'paypal'
  end

  # Gateways should not be accessed directly, and should instead reply on `gateway_url`
  private
  def paypal_url(return_path)
    values = {
      business: Rails.application.secrets.paypal_business_address,
      cmd: "_xclick",
      upload: 1,
      item_name: "Order ##{self.uuid}",
      return: "#{Rails.application.secrets.app_host}#{return_path}",
      invoice: self.uuid,
      amount: self.amount,
      notify_url: "#{Rails.application.secrets.app_host}/payment_processor/paypal"
    }
    "#{Rails.application.secrets.paypal_host}/cgi-bin/webscr?" + values.to_query
  end
end
