class MessagesController < ApplicationController
  include Api::V1::MessageParticipant

  before_action :find_messages, only: [:index]
  before_action :find_message, only: [:show, :destroy]
  load_and_authorize_resource class: 'MessageParticipant'

  def find_messages
    @messages = @current_user.all_messages
  end

  def find_message
    @message = @current_user.all_messages.find_by_message_id! params[:id] || params[:message_id]
  end

  def index
    respond_to do |format|
      format.json do
        render json: message_participants_json(@messages, params[:include] || {}), status: :ok
      end
    end
  end

  def show
    respond_to do |format|
      format.json do
        render json: message_participant_json(@message, params[:include] || {}), status: :ok
      end
    end
  end
end
