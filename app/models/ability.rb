class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # Logged in user
    unless user.new_record?
      can :read, User
      can :update, User, id: user.id
    end
  end
end
