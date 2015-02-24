module Api::V1::Message
  include Api::V1::Json
  include Api::V1::User

  def message_json(message, includes = {})
    attributes = %w(id subject body sender_id created_at)
    methods = %w(participants)
    msg = message.is_a?(Message) ? message : message.message

    api_json(msg, only: attributes, methods: methods).tap do |hash|
      mp = message.is_a?(Message) ? message.message_participants.find_by_user_id(@current_user.id) : message
      hash[:state] = mp.state if mp

      if includes.include? 'sender'
        hash[:sender] = user_json(msg.sender)
      end
    end
  end

  def messages_json(messages, includes = {})
    messages.map { |m| message_json(m, includes) }
  end
end