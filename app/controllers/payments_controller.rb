class PaymentsController < ApplicationController
  include Api::V1::Payment
  include PaginationHelper

  before_action :find_payments, only: [:index]

  load_and_authorize_resource find_by: :uuid

  PARAMS_FOR_JOB = %w(payment_method_nonce)

  def find_payments
    if api_request?
      @payments = @current_user.payments.order(created_at: :desc)
      @payments = @payments.failed if params[:scope] == 'failed'
      @payments = @payments.initiated if params[:scope] == 'initiated'
      @payments = @payments.processed if params[:scope] == 'processed'
    else
      @payments = []
    end
  end

  def index
    includes = params[:include] || []
    respond_to do |format|
      format.json do
        @payments = @payments.includes(:monetary_transaction) if includes.include? 'transaction'
        render json: pagination_json(@payments, :payments_json, includes), status: :ok
      end
      format.html
    end
  end

  def create
    @payment = @current_user.payments.new payment_params
    if @payment.save
      ReceivePaymentJob.perform_later(@payment, params.slice(*PARAMS_FOR_JOB))
      flash[:success] = 'Thank you!  Your funds should appear within a few minutes.'
      redirect_to payment_path @payment.uuid
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
