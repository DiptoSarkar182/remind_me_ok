# app/models/ability.rb

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.isAdmin?
      can :manage, :all
    else
      can :read, :all
    end
  end
end