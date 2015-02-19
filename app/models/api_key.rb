class ApiKey < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :key
  validates_presence_of :key_hint
  validates_presence_of :user_id

  before_validation :infer_values

  def infer_values
    self.expires_at ||= 5.years.from_now
    self.key_hint ||= key[0, 6]
    self.key = SecurityHelper.sha_hash(self.key) if self.key_changed?
  end

  def destroy
    self.expires_at = Time.now
    save
  end

  def expired?
    expires_at < Time.now
  end
end
