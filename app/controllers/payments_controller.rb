class PaymentsController < ApplicationController
  skip_authorize_resource only: [:success]
  load_and_authorize_resource find_by: :uuid, except: [:success]
  skip_before_filter :verify_authenticity_token, only: [:success]

  PARAMS_FOR_JOB = %w(payment_method_nonce)

  def create
    @payment = @current_user.payments.new payment_params
    if @payment.save
      ReceivePaymentJob.perform_later(@payment, params.slice(*PARAMS_FOR_JOB))
      flash[:success] = 'Thank you!  Your funds should appear within a few minutes.'
      redirect_to new_payment_path
    else
      flash[:error] = 'Oops, there was a problem processing your request'
      render 'new'
    end
  end

  private
  def payment_params
    params.require(:payment).permit(:amount)
  end
end
