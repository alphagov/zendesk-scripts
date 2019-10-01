require 'zendesk_api'
require 'rest-client'
require 'json'
require 'date'

require_relative 'zendesk-setup.rb'

# Setup vars

diag = "true"
url = "#{ENV['ZENDESK_URL']}/deleted_users/"
tomorrow = Date.today.next_day
lastyear = tomorrow - 365

# input_file = File.open "data/soft_deleted_users_test.json"

File.open "data/soft_deleted_users.json" do |input_file|

  file_data = JSON.load input_file

  # Main loop
  file_data.each do |user|

    # Extract some fields
    updated_at = user["updated_at"]
    last_login_at = user["last_login_at"]
    user_id = user["id"]
    active = user["active"]
    name = user["name"]

    # Print some vars so we can corellate script actions & logic
    if diag == "true"
      # puts "user: #{user.inspect}"
      puts "user_id: #{user_id}"
      puts "name: #{name}"
      puts "Active: #{active}"
      puts "url: #{url}"
      puts "tomorrow: #{tomorrow}"
      puts "lastyear: #{lastyear}"
      puts "last_login_at: #{last_login_at}"
      puts "updated_at: #{updated_at}"
      puts ". . . . . . . . . ."
    end

    # If permanently deleted, ignore this user_id
    if name != "Permanently deleted user"
      # Not permanently deleted so let's permanently delete
      if active != "true"
        puts "User #{user_id} already soft deleted, hard deleting..."
        begin
          # api does not support hard delete yet, so hard delete like this...
            full_url = "#{url}#{user_id}.json"
            RestClient::Request.execute method: :delete, url: full_url, user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD']
          
            rescue RestClient::Exception => api_error
              puts "Received error from ZenDesk API for user #{user_id} => #{api_error}"
              puts api_error.backtrace
              puts "Skipping over user #{user_id}"
            next
        end
      end
      puts "------------------------------------------------"
    else
      puts "NOT DELETING #{user_id} as already hard deleted"
      puts "------------------------------------------------"

    end
  end
end