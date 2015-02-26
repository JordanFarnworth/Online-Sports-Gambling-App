class Ability
  include CanCan::Ability

  # If you add a line to this file, make a spec for it in spec/models/ability_spec.rb
  def initialize(user)
    user ||= User.new

    # Logged in user
    unless user.new_record?
      can :read, User
      can :update, User, id: user.id

      # Messaging permissions
      can [:read, :destroy, :update], MessageParticipant, user_id: user.id
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
