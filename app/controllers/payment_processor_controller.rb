class PaymentProcessorController < ApplicationController
  skip_before_action :set_current_user
  skip_authorization_check
  skip_before_filter :verify_authenticity_token

  def paypal
    response = validate_paypal_IPN_notification(request.raw_post)
    payment = Payment.find_by! uuid: params[:invoice], gateway: 'paypal'
    payment.parameters = params
    case response
      when "VERIFIED"
        payment.state = 'processed'
        payment.amount = params['payment_gross'].to_f
        payment.save
      when "INVALID"
        payment.update state: 'failed'
      else
        # error
    end
    puts response
    render :nothing => true
  end

  protected
  def validate_paypal_IPN_notification(raw)
    uri = URI.parse(Rails.application.secrets.paypal_host + '/cgi-bin/webscr?cmd=_notify-validate')
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 60
    http.read_timeout = 60
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true
    response = http.post(uri.request_uri, raw,
                         'Content-Length' => "#{raw.size}",
                         'User-Agent' => "My custom user agent"
    ).body
  end
end
