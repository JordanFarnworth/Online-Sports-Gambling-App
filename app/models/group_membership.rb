class GroupMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  scope :active, -> { where(state: :active) }

  validates :group, uniqueness: { scope: :user }
  validates_inclusion_of :state, in: %w(active deleted)

  before_validation do
    self.state ||= :active
  end

  def destroy
    self.state = :deleted
    save
  end
end
