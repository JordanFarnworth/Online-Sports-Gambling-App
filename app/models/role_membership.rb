class RoleMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :role

  validates :role, uniqueness: { scope: :user }
  validates_presence_of :user
  validates_presence_of :role
  validates_inclusion_of :state, in: %w(active deleted)

  scope :active, -> { where(state: :active) }

  before_validation do
    self.state ||= :active
  end

  def destroy
    self.state = :deleted
    save
  end
end
