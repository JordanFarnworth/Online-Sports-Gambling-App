class GroupMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  scope :active, -> { where(state: :active) }
end
