require 'rails_helper'

RSpec.describe PageView, type: :model do
  it 'should mark a page view as being masqueraded' do
    pv = PageView.create user_id: 1, real_user_id: 2
    expect(pv.masqueraded?).to be_truthy
    expect(PageView.masqueraded).to include(pv)
  end
end
