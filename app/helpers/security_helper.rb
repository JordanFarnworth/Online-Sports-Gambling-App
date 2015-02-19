require 'bcrypt'
require 'securerandom'
module SecurityHelper

  def self.hash(*a)
    BCrypt::Password.create(a.join)
  end

  def self.get_session_key
    SecureRandom.base64 120
  end

  def self.sha_hash(*a)
    d = Digest::SHA2.new 512
    d << a.join
    d.to_s
  end

  def self.get_attachment_key
    SecureRandom.urlsafe_base64 60
  end

  def self.get_api_key
    SecureRandom.urlsafe_base64 60
  end
end
