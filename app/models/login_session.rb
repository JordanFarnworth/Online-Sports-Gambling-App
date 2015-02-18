class LoginSession < ActiveRecord::Base
  belongs_to :user

  def expired?
    expires_at < Time.now
  end

  def destroy
    self.expires_at = Time.now
    save
  end
end
