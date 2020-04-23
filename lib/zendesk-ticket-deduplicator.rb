require_relative 'zendesk-setup.rb'

require 'rest-client'
require 'json'

# Setup time window
window_start_time = Time.now - 2 * 3600
start_time = window_start_time.strftime('%Y-%m-%dT%H:%M:%S%z')

# Change date to 2020-01-01
search_results = @client.search(:query => "type:user role:end-user -name:Zendesk organization:none created_at>=#{start_time}")

# Calculate no. of pages to cycle through
user_count =  search_results.count
number_of_pages = (user_count.to_f / 100).ceil
results_file = "data/2020_user_ids.json"

puts "Number of User accounts (UIDs): #{user_count}, Number of pages of UIDs: #{number_of_pages}, Retrieving #{user_count} user accounts, this may take a while"

# Loop through users and write to file in JSON format
File.open(results_file, "w") do |file|
  (1..number_of_pages).each do |i|
    search_results.page(i).each do |user|
      file.puts(user.to_json)
    end
  end
end

first_line_group = 20188163

# Open the source file for reading
File.readlines(results_file).each do |line|
  user = JSON.parse(line)
  user_id = user["id"]

  # Count tickets for this user
  count = @client.search!(:query => "type:ticket group_id:#{first_line_group} requester:#{user_id} -status:closed -status:solved").count
  ticket_count = Integer count
  puts "User ID: #{user_id} has #{ticket_count} ticket/s"

  # If user has > 1 ticket, it's a candidate, if active, move user's tickets to new queue "Testing--Filtering group"
  if ticket_count > 1
    tickets = @client.search!(:query => "type:ticket group_id:#{first_line_group} requester:#{user_id} -status:closed -status:solved")
    ticket_index = 0
    ticket_id = []
    ticket_status = []
    new_group_id = 20395446
    url = "#{ENV['ZENDESK_URL']}/tickets/"

    # Loop though each ticket for user_id and migrate to new group

    while ticket_index < ticket_count do
      # Prepare payload
      ticket_to_update = {"ticket" => {"group_id" => new_group_id}}
      # Prepare ticket ID
      ticket_id[ticket_index] = tickets[ticket_index].id
      # Prepare ticket Status
      ticket_status[ticket_index] = tickets[ticket_index].status
      # Construct URL
      full_url = "#{url}#{tickets[ticket_index].id}.json"
      # For debug
      puts "Moving ticket - user_id: #{user_id} | ticket_id: #{ticket_id[ticket_index]} | full_url: #{full_url} | status: #{ticket_status[ticket_index]}"
      # Move the ticket
      RestClient::Request.execute(method: :put, url: full_url, user: ENV['ZENDESK_USER_EMAIL']+'/token', password: ENV['ZENDESK_TOKEN'], payload: ticket_to_update)
      # Next ticket
      ticket_index += 1
    end
  end
end
