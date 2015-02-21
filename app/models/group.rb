class Group < ActiveRecord::Base

  before_save :infer_values

  has_many :group_memberships
  has_many :users, through: :group_memberships

  serialize :settings, Hash

  def infer_values
    self.state ||= :active
  end

  def destroy
    self.state = :deleted
    group_memberships.destroy_all
    save
  end
end
