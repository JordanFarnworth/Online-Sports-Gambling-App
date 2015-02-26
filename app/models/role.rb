class Role < ActiveRecord::Base
  has_many :role_memberships, -> { active }
  has_many :users, -> { active }, through: :role_memberships

  validates :name, uniqueness: true, presence: true
  validates_inclusion_of :state, in: %w(active), if: :protected?

  serialize :permissions, Hash

  scope :active, -> { where(state: :active) }

  PERMISSION_TYPES = [
    { name: :manage_roles, component: :roles, description: 'Allows a user to create/edit/delete roles' },
    { name: :assign_roles, component: :roles, description: 'Allows a user to assign users to roles' }
  ]

  after_initialize do
    Role::PERMISSION_TYPES.each do |k, v|
      permissions[k[:name]] ||= false
    end
    if protection_type == 'administrator'
      permissions.each do |k, v|
        permissions[k] = true
      end
    end
    permissions.symbolize_keys!
    permissions.transform_values! { |x| ['1', 1, 't', true].include?(x) }
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
