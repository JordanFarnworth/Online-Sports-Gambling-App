require 'rails_helper'

RSpec.describe RolesHelper, type: :helper do
  it 'should load permissions from yml' do
    expect(RolesHelper.permissions.empty?).to be_falsey

    RolesHelper.permissions.each do |k, v|
      expect(v.keys).to eql ['component', 'description']
    end
  end
end
