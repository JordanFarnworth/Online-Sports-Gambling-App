require 'csv'

namespace :test_data do
  desc "Loads users into the database for testing"
  task users: :environment do
    csv = CSV.open "#{File.dirname(__FILE__)}/data/users.csv", headers: true
    User.transaction do
      csv.each do |c|
        User.create username: c['username'], display_name: c['display_name'], email: c['email'], password: c['password']
      end
    end
  end

end
