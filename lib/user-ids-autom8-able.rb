require 'zendesk_api'
require 'rest-client'
require 'json'

require_relative 'zendesk-setup.rb'

lastyear = Date.today.next_day - 365
source_user_file = "data/selected_user_ids_meeting_gdpr_params.json"

search_results = @client.search(:query => "type:user role:end-user -name:Zendesk organization:none created<=#{lastyear}")

# The Zendesk API has 100 items per page, so programatically
# determine how many pages we have by rounding to the nearest 100.
# Retrieve all these users to a local file and then process locally.

user_count =  search_results.count
number_of_pages = (user_count.to_f / 100).ceil

puts "Retrieving #{user_count} user accounts, this may take a while"

File.open(source_user_file, "w") do |file|

# Loop through users matching criteria and 2 stage delete (soft then hard)

  (1..number_of_pages).each do |i|
    search_results.page(i).each do |user|
      file.puts(user.to_json)
    end
  end
end

# some date fields have the value 'null' but we need to compare dates, so
FALSE_DATE = "2012-01-01"

# Setup the log file
log_file_name = ENV['ZENDESK_LOG_FILE']
File.open(log_file_name, "w") do |log_file|

  File.readlines(source_user_file).each do |line|
    user = JSON.parse(line)

    # Extract some fields
    updated_at = user["updated_at"]
    last_login_at = user["last_login_at"]
    user_id = user["id"]
    active = user["active"]

    # is user account already soft deleted, if so, fast track to hard delete
    if active != "true"
      message = "user account #{user_id} is already soft deleted"
      puts message
      log_file.puts message

      updated_at = FALSE_DATE
      last_login_at = FALSE_DATE
    else
      # user account is NOT soft deleted, so test for null dates and set false date
      if updated_at.nil?
        updated_at = FALSE_DATE
      end

      if last_login_at.nil?
        last_login_at = FALSE_DATE
      end

    end

    # parse dates so we can do comparisons
    updated = Date.parse(updated_at)
    last_login = Date.parse(last_login_at)

    # base URL for soft / hard delted user accounts
    url = "#{ENV['ZENDESK_URL']}/deleted_users/"

    if last_login <= lastyear
      if updated <= lastyear
        # Potential DELETION candidate - check tickets
        count = @client.search!(:query => "type:ticket requester:#{user_id}").count
        ticket_count = Integer count

        message = "ticket_count: #{ticket_count}"
        puts message
        log_file.puts message

        if ticket_count == 0
          message = "Soft deleting user_id: #{user_id}"
          puts message
          log_file.puts message

          begin
            @client.users.destroy!(:id => user_id)

          rescue ZendeskAPI::Error::RecordInvalid => api_error
            message = "Received error user #{user_id} already deleted, skipping over"
            puts message
            log_file.puts message
            next

          end

          message = "Hard deleting user_id: #{user_id}"
          puts message
          log_file.puts message

          begin
            # api does not support hard delete yet, so hard delete like this...
            full_url = "#{url}#{user_id}.json"
            puts "full_url: #{full_url}"
            RestClient::Request.execute(method: :delete, url: full_url, user: ENV['ZENDESK_USER_EMAIL']+'/token', password: ENV['ZENDESK_TOKEN'])

          rescue RestClient::Exception => api_error
            message = "Received error from ZenDesk API Skipping over user #{user_id} => #{api_error}"
            puts message
            log_file.puts message

            puts api_error.backtrace
            next

          end

        else
          message = "user_id: #{user_id} has #{ticket_count} tickets, not deleting"
          puts message
          log_file.puts message

        end
      end
    end
  end
end
puts "- - - - Zendesk User Account deletion has completed - - - -"