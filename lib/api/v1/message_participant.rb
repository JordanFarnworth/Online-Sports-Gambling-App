module Api::V1::MessageParticipant
  include Api::V1::Json
  include Api::V1::Message

  def message_participant_json(message_participant, includes = {})
    attributes = %w(id message_id user_id state created_at)

    api_json(message_participant, only: attributes).tap do |hash|
      if includes.include? 'message'
        hash[:message] = message_json(message_participant.message, includes)
      end
    end
  end

  def message_participants_json(message_participants, includes = {})
    message_participants.map { |m| message_participant_json(m, includes) }
  end
end