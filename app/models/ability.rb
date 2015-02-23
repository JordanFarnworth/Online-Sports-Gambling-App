class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # Logged in user
    unless user.new_record?
      can :read, User
      can :update, User, id: user.id

      # Messaging permissions
      can [:read, :destroy, :update], MessageParticipant do |msg|
        msg.user == user
      end
      can :read, Message
      can :create, Message

      # Group permissions
      can :manage, Group
    end
  end
end
