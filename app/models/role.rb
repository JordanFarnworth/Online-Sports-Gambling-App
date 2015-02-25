class Role < ActiveRecord::Base
  has_many :role_memberships, -> { active }
  has_many :users, -> { active }, through: :role_memberships

  validates_presence_of :name
  validates_inclusion_of :state, in: %w(active), if: :protected?

  serialize :permissions, Hash

  scope :active, -> { where(state: :active) }

  after_initialize do
    RolesHelper.permissions.each do |k, v|
      permissions[k] ||= false
    end
  end

  before_validation do
    self.state ||= :active
  end

  def destroy
    self.state = :deleted
    save
  end

  def protected?
    !!protection_type
  end
  alias :protected :protected?

  def add_user(user)
    rp = RoleMembership.find_or_create_by(role: self, user: user)
    rp.update state: :active
    rp
  end
end
