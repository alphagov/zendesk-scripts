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

diag = "true"
url = "#{ENV['ZENDESK_URL']}/deleted_users/"
day = Date.today.next_day
lastyear = day - 365

input_file = File.open "data/soft_deleted_users.json"

file_data = JSON.load input_file

# Main loop
file_data.each do |user|

  # Extract some fields
  updated_at = user["updated_at"]
  last_login_at = user["last_login_at"]
  user_id = user["id"]
  active = user["active"]
  name = user["name"]
  permanently_deleted = user["permanently_deleted"]
  
  # Print some vars so we can corellate script actions & logic

  if diag == "true"
    puts "url: #{url}"
    puts "day: #{day}"
    puts "lastyear: #{lastyear}"
    puts "user_id: #{user_id}"
    puts "name: #{name}"
    puts "Active: #{active}"
    puts "last_login_at: #{last_login_at}"
    puts "updated_at: #{updated_at}"
    puts "permanently_deleted: #{permanently_deleted}"
    puts "-----------------------------------------------------"
  end

  # If permanently deleted, ignore this user_id
  if permanently_deleted != "true"
    # Not permanently deleted so let's check and permanently delete
    if active != "true"
      puts "User #{user_id} already soft deleted, hard deleting..."
      sleep 1
      begin
        # api does not support hard delete yet, so hard delete like this...
          full_url = "#{url}#{user_id}.json"
          RestClient::Request.execute method: :delete, url: full_url, user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD']
    
          rescue RestClient::UnprocessableEntity => api_error
            puts "Received HTTP 422 from ZenDesk API for user #{user_id} => #{api_error}"
            puts api_error.backtrace
            puts "Skipping over user #{user_id}"
          next
    
          rescue RestClient::Exception => api_error
            puts "Received error from ZenDesk API for user #{user_id} => #{api_error}"
            puts api_error.backtrace
            puts "Skipping over user #{user_id}"
          next
      end
    end
  else
    puts "NOT DELETING #{user_id} as already hard deleted"
    puts "------------------------------------------------"

  end
end


# Legacy code chunks

#   ticket_count = 0
#   end
  # Convert strings to dates, if strings are nil then set a false date of 2012 so comparison works.

  # This works for single line test file
# file = File.open input_file
# file_data = JSON.load file
# file.close

# tried this but it's not a good method for this problem
# file_data = JSON.parse(File.read(input_file).to_json)
# puts file_data

    # if updated_at != nil
    #   # parse the date so we can do comparisons
    #   updated = Date.parse(updated_at)
    # else
    #   # account has not been updated so consider for deletion
    #   updated_at = false_date
    #   updated = Date.parse(updated_at)
    # end

    # if last_login_at != nil
    #   last_login = Date.parse(last_login_at)
    # else
    #   last_login_at = false_date
    #   last_login = Date.parse(last_login_at)
    # end

    # diagnostics 


  # If last logged in < last year, let's check whether user has any tickets associated

    # if last_login <= lastyear
    #   puts "Potential DELETION candidate - check tickets"
    #   count = @client.search!(:query => "requester_id:#{user_id}").count
    #   ticket_count = Integer count
    #   puts "ticket_count: #{ticket_count}"

    #   if ticket_count == 0
    #     # soft delete then hard delete this user as not already soft deleted.
    #     puts "ok no tickets so we're ready, DELETE this user: #{user_id}"
  
    #     begin
    #       @client.users.destroy!(:id => user_id)
    #       rescue ZendeskAPI::Error::RecordInvalid => api_error
    #         puts "Received error user #{user_id} already deleted"
    #         puts "Skipping over user #{user_id}"
    #       next
    #     end
    #   else
    #   puts "DO NOT DELETE, Tickets owned"
    #   end
    # end
  
    # begin
    # # api does not support hard delete yet, so hard delete like this...
    # #  RestClient::Request.execute (method: :delete, url: "#{ENV['ZENDESK_URL']}/deleted_users/#{user_id}.json user: #{ENV['ZENDESK_USER_EMAIL']} password: #{ENV['ZENDESK_USER_PASSWORD']}")
    #   full_url = "#{url}#{user_id}.json"
    #   RestClient::Request.execute method: :delete, url: full_url, user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD']

    #   rescue RestClient::UnprocessableEntity => api_error
    #     puts "Received HTTP 422 from ZenDesk API for user #{user_id} => #{api_error}"
    #     puts api_error.backtrace
    #     puts "Skipping over user #{user_id}"
    #   next

    #   rescue RestClient::Exception => api_error
    #     puts "Received error from ZenDesk API for user #{user_id} => #{api_error}"
    #     puts api_error.backtrace
    #     puts "Skipping over user #{user_id}"
    #   next

    # end

    # false_date = "2012-01-01"
