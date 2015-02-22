module Api::V1::Message
  include Api::V1::Json

  def message_json(message, includes = {})
    attributes = %w(id subject body sender_id)
    methods = %w(participants)

    api_json(message, only: attributes, methods: methods).tap do |hash|
      mp = message.message_participants.find_by_user_id @current_user.id
      hash[:state] = mp.state if mp
    end
  end

  def messages_json(messages, includes = {})
    messages.map { |m| message_json(m, includes) }
  end
end