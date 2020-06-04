require 'date'
require 'json'
require 'zendesk_api'
require_relative 'zendesk_setup'
@client = create_zendesk_client_from_env(ENV)

tomorrow = Date.today.next_day
lastyear = tomorrow - 365

puts "Total Groups: #{@client.groups.count}"
# Output csv column headings
puts "Group ID,Group Name,Group Total Tickets,Group Deletable Tickets"

File.open "data/groups.json" do |input_file|
  groups = JSON.load input_file

  # Main loop starts
  groups.each do |url|

    group_id = url["id"]
    group_name = url["name"]

    # Count total tickets per group
    group_total_tickets = @client.search(:query => "type:ticket group_id:#{group_id}").count.to_i
    # Count deletable tickets per group
    group_deletable_tickets = @client.search(:query => "type:ticket group_id:#{group_id} organization_id:none status:closed updated_at>=2012-01-01 updated_at<#{lastyear}").count.to_i
    # gsub replaces , with - so that csv import is clean
    puts "#{group_id},#{group_name.gsub(', ', '-')},#{group_total_tickets},#{group_deletable_tickets}"
  end
end
