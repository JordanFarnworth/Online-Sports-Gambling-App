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
      can :search_recipients, Message

      # Group permissions
      can :manage, Group

      # Role permissions
      can :read, Role if user.has_permission?(:manage_roles) || user.has_permission?(:assign_roles)
      can(:manage, Role) { |r| !r.protected? } if user.has_permission?(:manage_roles)
    end
  end
end
