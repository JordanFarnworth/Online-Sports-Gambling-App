class Group < ActiveRecord::Base

  before_create :default_settings
  before_validation :infer_values


  has_many :group_memberships, -> { active }
  has_many :users, -> { active }, through: :group_memberships
  has_many :lobbies

  serialize :settings, Hash

  scope :active, -> { where(state: :active) }

  validates :name, length: { minimum: 3 }
  validates_inclusion_of :state, in: %w(active deleted)

  def infer_values
    self.state ||= :active
  end

  def add_user(user)
    rp = GroupMembership.find_or_create_by(group: self, user: user)
    rp.update state: :active
    rp
  end

  def default_settings
    self.settings[:max_users] ||= 10
    self.settings[:availability] ||= "Public"
    self.settings[:max_lobbies] ||= 20
    self.settings[:description] ||= "This group is going to be great!"
  end

  def destroy
    self.state = :deleted
    group_memberships.destroy_all
    save
  end
end
