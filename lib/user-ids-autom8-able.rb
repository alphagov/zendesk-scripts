require 'zendesk_api'
require 'rest-client'
require 'json'

require_relative 'zendesk-setup.rb'

lastyear = Date.today.next_day - 365
source_user_file = "data/selected_user_ids_meeting_gdpr_params.json"

$output_to_console = ENV.fetch('OUTPUT_TO_CONSOLE', 'false').to_s.downcase == "true" 

puts "Outputting to console: #{$output_to_console}"

def hard_delete(user_id, url, log_file)
  message = "Hard deleting user_id: #{user_id}"
  if $output_to_console
    puts message
  end
  log_file.puts message

  begin
    # api does not support hard delete yet, so hard delete like this...
    full_url = "#{url}#{user_id}.json"
    if $output_to_console
      puts "full_url: #{full_url}"
    end
    RestClient::Request.execute(method: :delete, url: full_url, user: ENV['ZENDESK_USER_EMAIL']+'/token', password: ENV['ZENDESK_TOKEN'])

  rescue RestClient::Exception => api_error
    message = "Received error from ZenDesk API Skipping over user #{user_id} => #{api_error}"
    if $output_to_console
      puts message
    end
    log_file.puts message

    return false
  end
  return true
end

search_results = @client.search(:query => "type:user role:end-user -name:Zendesk organization:none created<=#{lastyear}")

# The Zendesk API has 100 items per page, so programatically
# determine how many pages we have by rounding to the nearest 100.
# Retrieve all these users to a local file and then process locally.

user_count =  search_results.count
number_of_pages = (user_count.to_f / 100).ceil

if $output_to_console
  puts "Retrieving #{user_count} user accounts, this may take a while"
end

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

    # is the user a shared agent (connected to another zendesk account)
    # then skip as we cannot delete them
    if user["shared_agent"]
      message = "user account #{user_id} cannot be deleted as it is marked as a 'shared_agent' from another zendesk account"
      if $output_to_console
        puts message
      end
      log_file.puts message
      next
    end

    # base URL for soft / hard delted user accounts
    url = "#{ENV['ZENDESK_URL']}/deleted_users/"

    # is user account already soft deleted, if so, hard delete
    if active.to_s == "false"
      message = "user account #{user_id} is already soft deleted"
      if $output_to_console
        puts message
      end
      log_file.puts message
      hard_delete(user_id, url, log_file)
      next
    end

    # Prepare and parse dates so we can do comparisons
    if updated_at.nil?
      updated_at = FALSE_DATE
    end
    if last_login_at.nil?
      last_login_at = FALSE_DATE
    end
    updated = Date.parse(updated_at)
    last_login = Date.parse(last_login_at)

    if last_login <= lastyear
      if updated <= lastyear
        # Potential DELETION candidate - check tickets
        count = @client.search!(:query => "type:ticket requester:#{user_id}").count
        ticket_count = Integer count

        message = "ticket_count: #{ticket_count}"
        if $output_to_console
          puts message
        end
        log_file.puts message

        if ticket_count == 0
          message = "Soft deleting user_id: #{user_id}"
          if $output_to_console
            puts message
          end
          log_file.puts message

          begin
            @client.users.destroy!(:id => user_id)

          rescue ZendeskAPI::Error::RecordInvalid => api_error
            message = "Received error user #{user_id} already deleted, skipping over. Details: #{api_error.backtrace}"
            if $output_to_console
              puts message
            end
            log_file.puts message
            next

          rescue ZendeskAPI::Error::ReadTimeout => api_error
            message = "Received network error deleting user #{user_id}, skipping over. Details: #{api_error.backtrace}"
            if $output_to_console
              puts message
            end
            log_file.puts message
            next

          rescue ZendeskAPI::Error::NetworkError => api_error
            message = "Received network error, check user #{user_id}, skipping over. Details: #{api_error.backtrace}"
            if $output_to_console
              puts message
            end
            log_file.puts message
            raise
          end

          hard_delete(user_id, url, log_file)

        else
          message = "user_id: #{user_id} has #{ticket_count} tickets, not deleting"
          if $output_to_console
            puts message
          end
          log_file.puts message

        end
      end
    end
  end
end
puts "- - - - Zendesk User Account deletion has completed - - - -"
