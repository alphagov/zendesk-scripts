require 'zendesk_api'
require 'rest-client'
require 'json'
require 'date'

require_relative 'zendesk_setup'

# Setup vars

diag = "true"
url = "#{ENV['ZENDESK_URL']}/deleted_users/"
lastyear = Date.today.next_day - 365

File.open "data/soft_deleted_users.json" do |input_file|

  file_data = JSON.load input_file

  file_data.each do |user|


    # Extract some fields
    updated_at = user["updated_at"]
    last_login_at = user["last_login_at"]
    user_id = user["id"]
    active = user["active"]
    name = user["name"]

    # Convert strings to dates, if strings are nil then set a false date of 2012 so comparison works.
    # Booleans returned by API are not true boolean but strings.

    hard_delete = "false"

    if active == "false"
      # account is already soft deleted so force hard delete
      hard_delete = "true"
    end

    false_date = "2012-01-01"
    ticket_count = 0

    if hard_delete != "true"
      if updated_at.nil?
        updated_at = false_date
      end

      # parse the date so we can do comparisons

      if last_login_at.nil?
        last_login_at = false_date
      end
      last_login = Date.parse(last_login_at)

      # diagnostics 

      if diag == "true"
        puts "user_id: #{user_id}"
        puts "Name: #{name}"
        puts "Active: #{active}"
        puts "last_login_at: #{last_login_at}"
        puts "last_login: #{last_login}"
        puts "url: #{url}"
        puts "lastyear: #{lastyear}"
      end

      # If last logged in < last year, let's check whether user has any tickets associated

      if last_login <= lastyear
        puts "Potential DELETION candidate - check tickets"
        count = @client.search!(:query => "requester_id:#{user_id}").count
        ticket_count = Integer count
        puts "ticket_count: #{ticket_count}"
      else
        puts "DO NOT DELETE"
      end
    end
    
    if ticket_count == 0
      # soft delete
      puts "ok we're ready, DELETE this user: #{user_id}"
      puts "DELETE User ID: #{user_id}"

      begin
        @client.users.destroy!(:id => user_id)
        rescue ZendeskAPI::Error::RecordInvalid => api_error
          puts "Received error user #{user_id} already deleted"
          puts "Skipping over user #{user_id}"
        next
      end

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
    else
      puts "NOT DELETING #{user_id}"
    end
    puts "---------------------------------"
  end
end