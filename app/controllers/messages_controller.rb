class MessagesController < ApplicationController
  include Api::V1::Message
  include PaginationHelper

  before_action :find_messages, only: [:index]
  before_action :find_message, only: [:show, :destroy, :update]
  load_and_authorize_resource

  API_ALLOWED_FIELDS = %w(state)

  def find_messages
    return unless logged_in?
    @messages = @current_user.all_messages
  end

  def find_message
    return unless logged_in?
    @message = @current_user.all_messages.find_by! message_id: (params[:id] || params[:message_id])
  end

  def index
    respond_to do |format|
      format.json do
        render json: pagination_json(@messages, :messages_json, params[:include] || {}), status: :ok
      end
    end
  end

  def show
    respond_to do |format|
      format.json do
        render json: message_json(@message, params[:include] || {}), status: :ok
      end
    end
  end

  def create
    @message = Message.new message_params
    @message.sender = @current_user
    saved = @message.save
    respond_to do |format|
      format.json do
        if saved
          render json: message_json(@message, params[:include] || {}), status: :ok
        else
          render json: @message.errors, status: :bad_request
        end
      end
    end
  end

  def destroy
    @message.destroy
    respond_to do |format|
      format.json do
        render json: {}, status: :no_content
      end
    end
  end

  def update
    if @message.update(params[:message].slice(*API_ALLOWED_FIELDS))
      render json: message_json(@message), status: :ok
    else
      render json: @message.errors, status: :bad_request
    end
  end

  private
  def message_params
    if params[:action] == 'create'
      params.require(:message).permit(:subject, :body, message_participants_attributes: [:id, :user_id])
    else
      params.require(:message).permit(*API_ALLOWED_FIELDS)
    end
  end
end
