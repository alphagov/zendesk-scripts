require_relative 'zendesk-setup.rb'

require 'rest-client'
require 'json'

puts "Total Users on the system: #{@client.users.count}"

# Change date to 2020-01-01
search_results = @client.search(:query => "type:user role:end-user -name:Zendesk organization:none created_at>=2020-04-13")

user_count =  search_results.count
number_of_pages = (user_count.to_f / 100).ceil

puts "Number of User accounts (UIDs): #{user_count}"
puts "Number of pages of UIDs: #{number_of_pages}"
puts "Retrieving #{user_count} user accounts, this may take a while"

# Reset name after testing - Set Logfile name
results_file = "data/2020_user_ids.json"

# Loop through users and write to file in JSON format
File.open(results_file, "w") do |file|
  (1..number_of_pages).each do |i|
    search_results.page(i).each do |user|
      file.puts(user.to_json)
    end
  end
end

# Setup the log file
log_file_name = ENV['ZENDESK_LOG_FILE']
File.open(log_file_name, "w") do |log_file|

  # Open the source file for reading
  File.readlines(results_file).each do |line|
    user = JSON.parse(line)
    user_id = user["id"]

    # Extract some fields
    # updated_at = user["updated_at"]
    # last_login_at = user["last_login_at"]
    # active = user["active"]

    # Count tickets for this user
    count = @client.search!(:query => "type:ticket requester:#{user_id}").count
    ticket_count = Integer count

    # Message and log the result
    message = "User ID: #{user_id} has #{ticket_count} ticket/s"
    log_file.puts message
    puts message

    # If user has > 1 ticket, it's a candidate, if active, move user's tickets to new queue "Testing--Filtering group"
    if ticket_count > 1
      tickets = @client.search!(:query => "type:ticket requester:#{user_id}")
      ticket_index = 0
      ticket_id = []
      ticket_status = []
      new_group_id = 20395446
      url = "#{ENV['ZENDESK_URL']}/tickets/"

      # Loop though each ticket for user_id and migrate to new group
      # todo - get ticket contents, status field and check for solved or closed,
      #   if so ignore that ticket but continue with any others belonging to this UID
      # Ref:         "status": "solved"

      while ticket_index < ticket_count do
        # Prepare payload
        ticket_to_update = {"ticket" => {"group_id" => new_group_id}}

        # Prepare ticket ID
        ticket_id[ticket_index] = tickets[ticket_index].id

        # Prepare ticket Status
        ticket_status[ticket_index] = tickets[ticket_index].status

        # Construct URL
        full_url = "#{url}#{ticket_id[ticket_index]}.json"

        # if ticket_status != "solved" and ticket_status != "closed" move it
        if (ticket_status[ticket_index] != "solved") && (ticket_status[ticket_index] != "closed")

          # For debug
          message = "Moving ticket - user_id: #{user_id} | ticket_id: #{ticket_id[ticket_index]} | full_url: #{full_url} | status: #{ticket_status[ticket_index]}"
          log_file.puts message
          puts message

          # Move the ticket
          RestClient::Request.execute(method: :put, url: full_url, user: ENV['ZENDESK_USER_EMAIL']+'/token', password: ENV['ZENDESK_TOKEN'], payload: ticket_to_update)
        end

        # Next ticket
        ticket_index += 1
      end
    end
  end
end
