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

  desc 'Creates new messages amongst users'
  task :messages, [:num_of_messages] => :environment do |t, args|
    require 'securerandom'
    users = User.active.pluck(:id)
    args.with_defaults(num_of_messages: users.length * 10)
    num_of_messages = args.num_of_messages.to_i
    Message.transaction do
      num_of_messages.times do |i|
        puts "Creating message #{i.to_s}/#{num_of_messages}" if i % (num_of_messages / 100) == 0
        num_of_recips = SecureRandom.random_number(50) + 1
        recips = num_of_recips.times.to_a.map { |j| users[SecureRandom.random_number(users.length)] }.uniq
        sender = users[SecureRandom.random_number(users.length)]
        recips.delete_if { |j| j == sender }
        # Skip if the message will be sent to sender and only sender
        next if recips.empty?

        Message.create subject: SecureRandom.uuid, body: SecureRandom.urlsafe_base64(100), sender_id: sender,
          message_participants_attributes: recips.map { |j| { user_id: j } }
      end
      puts "Committing changes to database"
    end
  end

end
