require 'zendesk_api'
require 'rest-client'
require 'json'
require 'date'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']
  config.retry = true
end

# Setup vars

# diag = "false"
diag = "true"

day = Date.today.next_day
lastyear = day - 365
false_date = "2012-01-01"

# Initialise input file

input_file = "data/users-to-delete-TEST.jsonl"

# puts Dir.pwd

# Read from the file
# file contains user accounts selected using
# search(:query => "type:user created_at<#{lastyear} updated_at<#{lastyear} role:end-user -name:Zendesk organization_id:none")
# so we only need to check last_login_at and no. of tickets > 0

# This works for single line test file
# file = File.open input_file
# file_data = JSON.load file
# file.close


# json = JSON.parse(File.load("data/users-to-delete-TEST.jsonl"))

file_data = JSON.parse(File.read('data/users-to-delete.jsonl'))
file_data.each do |user|

  # Extract some fields
  updated_at = user["updated_at"]
  last_login_at = user["last_login_at"]
  user_id = user["id"]
  active = user["active"]
  name = user["name"]

  # Convert strings to dates, if strings are nil then set a false date of 2012 so comparison works.

  if active == "false"
    # account is already soft deleted so force hard delete
    hard_delete = "true"
  end

  if hard_delete != "true"
    if updated_at != nil
      # parse the date so we can do comparisons
      updated = Date.parse(updated_at)
    else
      # account has not been updated so consider for deletion
      updated_at = false_date
      updated = Date.parse(updated_at)
    end

    if last_login_at != nil
      last_login = Date.parse(last_login_at)
    else
      last_login_at = false_date
      last_login = Date.parse(last_login_at)
    end

    # diagnostics 

    if diag == "true"
      # puts "day: #{day}"
      # puts "lastyear: #{lastyear}"
      puts "user_id: #{user_id}"
      puts "Name: #{name}"
      # puts "file_data: #{file_data}"
      # puts "updated_at: #{updated_at}"
      puts "updated: #{updated}"
      # puts "last_login_at: #{last_login_at}"
      puts "last_login: #{last_login}"
    end

  # If last logged in < last year, let's check whether user has any tickets associated

    if last_login <= lastyear
      puts "DELETE candidate - check tickets"
      count = @client.search!(:query => "requester_id:#{user_id}").count
      ticket_count = Integer count
      puts "ticket_count: #{ticket_count}"
    else
      puts "DO NOT DELETE"
    end
  else
  ticket_count = 0
  end
  
  if ticket_count == 0
    # soft delete
    puts "ok we're ready, DELETE this user: #{user_id}"
    puts "DELETE #{user_id}"
    @client.users.destroy!(:id => user_id)
    
    begin
    # api does not support hard delete yet, so...
    #  RestClient::Request.execute (method: :delete, url: "#{ENV['ZENDESK_URL']}/deleted_users/#{user_id}.json user: #{ENV['ZENDESK_USER_EMAIL']} password: #{ENV['ZENDESK_USER_PASSWORD']}")
  
      RestClient::Request.execute method: :delete, url: "#{ENV['ZENDESK_URL']}/deleted_users/#{user_id}.json", user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD']

      rescue RestClient::UnprocessableEntity => api_error
        puts "Received HTTP 422 from ZenDesk API for user #{user_id} => #{api_error}"
        puts api_error.backtrace
        puts "Skipping over user #{user_id}"
      next

      rescue RestClient::Error::NetworkError => api_error
        puts "Received error from ZenDesk API for user #{user_id} => #{api_error}"
        puts api_error.backtrace
        puts "Skipping over user #{user_id}"
      next

    end
  else
    puts "NOT DELETING #{user_id}"
  end
  puts "---------------------------------"
end
