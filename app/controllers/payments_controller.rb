class PaymentsController < ApplicationController
  skip_authorize_resource only: [:success]
  load_and_authorize_resource find_by: :uuid, except: [:success]
  skip_before_filter :verify_authenticity_token, only: [:success]

  def create
    @payment = @current_user.payments.new payment_params
    if @payment.save
      redirect_to @payment.gateway_url(payment_success_path(@payment.uuid))
    else
      render 'new'
    end
  end

  def success
    @payment = Payment.find_by_uuid! params[:payment_id]
    authorize! :show, @payment
    flash[:success] = 'Payment received!  Your account will be updated momentarily.'
    render 'show'
  end

  private
  def payment_params
    params.require(:payment).permit(:gateway, :amount)
  end
end
