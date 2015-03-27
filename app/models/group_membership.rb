class GroupMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  scope :active, -> { where(state: :active) }

  validates :group, uniqueness: { scope: :user }
  validates_inclusion_of :state, in: %w(active deleted)
  validates_each :group, :user do |record, attr, value|
    record.errors.add attr, 'must be active' if value.nil? || !value.active?
  end

  before_validation do
    self.state ||= :active
  end

  def destroy
    self.state = :deleted
    save
  end
end
