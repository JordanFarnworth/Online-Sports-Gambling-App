class Ability
  include CanCan::Ability

  # If you add a line to this file, make a spec for it in spec/models/ability_spec.rb
  def initialize(user)
    user ||= User.new

    # Logged in user
    unless user.new_record?
      can :create, User
      can :read, User
      can :update, User#, id: user.id

      can [:destroy, :create], User # Remove when users become more granular

      can :masquerade, User do |u|
        Role::PERMISSION_TYPES.all? do |g|
          u.has_permission?(g[:name]) ? user.has_permission?(g[:name]) : true
        end && u != user
      end
      cannot :masquerade, User unless user.has_permission?(:become_users)

      # Messaging permissions
      can [:read, :destroy, :update], MessageParticipant, user_id: user.id
      can :read, Message
      can :create, Message
      can :search_recipients, Message

      # Group permissions
      can :manage, Group

      # Role permissions
      if user.has_permission? :manage_roles
        can :read, Role
        can(:manage, Role) { |r| !r.protected? }
      end
      if user.has_permission? :assign_roles
        can :read, Role
        can :read, User
        can :manage, RoleMembership
      end

      # Payments
      can :create, Payment
      can :read, Payment, user_id: user.id
    end
  end
end
