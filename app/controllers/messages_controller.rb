class MessagesController < ApplicationController
  include Api::V1::Message
  include PaginationHelper

  before_action :find_messages, only: [:index]
  before_action :find_message, only: [:show, :destroy, :mark_as_read]
  load_and_authorize_resource

  def find_messages
    @messages = @current_user.messages
  end

  def find_message
    @message = @current_user.messages.find params[:id] || params[:message_id]
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
    mp = @message.message_participants.find_by_user_id! @current_user.id
    mp.destroy
    respond_to do |format|
      format.json do
        render json: {}, status: :no_content
      end
    end
  end

  def mark_as_read
    authorize! :mark_as_read, @message
    mp = @message.message_participants.find_by_user_id! @current_user.id
    mp.mark_as_read!
    respond_to do |format|
      format.json do
        render json: message_json(@message), status: :ok
      end
    end
  end

  private
  def message_params
    params.require(:message).permit(:subject, :body, message_participants_attributes: [:id, :user_id])
  end
end
