class LoginSession < ActiveRecord::Base
  belongs_to :user

  before_save :infer_values

  def infer_values
    self.expires_at ||= 1.week.from_now
  end

  def expired?
    expires_at < Time.now
  end

  def destroy
    self.expires_at = Time.now
    save
  end
end
