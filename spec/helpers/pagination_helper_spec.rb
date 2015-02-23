require 'rails_helper'

RSpec.describe PaginationHelper, :type => :helper do
  include PaginationHelper
  describe 'small number pagination' do
    before(:all) do
      user
      user
    end

    it 'should paginate results using given parameters' do
      users = User.all.paginate(pagination_help({ page: 1, per_page: 1 }))
      expect(users.length).to eql 1
      next_users = User.all.paginate({ page: 2, per_page: 1 })
      expect(users).to_not eql next_users
    end

    it 'should default to 1 per page if the per_page param is lower' do
      users = User.all.paginate(pagination_help({ page: 1, per_page: 0 }))
      expect(users.length).to eql 1
    end
  end

  describe 'large number pagination' do
    before(:all) do
      User.transaction do
        150.times do |i|
          user
        end
      end
    end

    it 'should default to 50 per page if no per_page is included' do
      users = User.all
      expect(users.length).to be_between(100, (2 ** 31) - 1) # max 4-byte int value
      users = User.all.paginate(pagination_help({}))
      expect(users.length).to eql 50
    end

    it 'should default to 100 per page if the per_page is higher than 100' do
      users = User.all.paginate(pagination_help({ per_page: 200 }))
      expect(users.length).to eql 100
    end
  end

end