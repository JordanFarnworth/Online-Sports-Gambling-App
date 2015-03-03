require 'rails_helper'

RSpec.describe SecurityHelper, type: :helper do

  it 'should hash with bcrypt' do
    str = SecureRandom.uuid
    crypted = SecurityHelper.hash str
    expect(str).to_not eql crypted

    plain_text = BCrypt::Password.new crypted
    expect(plain_text == str).to be_truthy
  end
end
