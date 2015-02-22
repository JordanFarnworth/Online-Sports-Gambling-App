class GroupMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  scope :active, -> { where(state: :active) }

  before_validation do
    self.state ||= :active
  end

  def destroy
    self.state = :deleted
    save
  end
end
