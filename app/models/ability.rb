class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # Logged in user
    unless user.new_record?
      can :read, User
      can :update, User, id: user.id
      can [:read, :destroy, :mark_as_read], Message do |msg|
        msg.users.include? user
      end
      can :create, Message
    end
  end
end
