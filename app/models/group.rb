class Group < ActiveRecord::Base

  before_save :infer_values

  has_many :group_memberships, -> { active },
  has_many :users, -> { active }, through: :group_memberships

  serialize :settings, Hash

  scope :active, -> { where(state: :active) }

  def infer_values
    self.state ||= :active
  end

  def destroy
    self.state = :deleted
    group_memberships.destroy_all
    save
  end
end
