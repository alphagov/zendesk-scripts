require 'zendesk_api'

require_relative 'zendesk-setup.rb'

group_id = ENV['ZENDESK_GROUP']

lastyear = Date.today.prev_day - 365

current_year = Time.now.year
year = 2012
tickets = 0
total_tickets = 0

puts "Deletable tickets by year"

until year == current_year do
  if lastyear.year == year then
    tickets = @client.search(:query => "type:ticket group_id:#{group_id} status:closed organization_id:none updated_at>=#{year}-01-01 updated_at<#{lastyear}").count.to_i
  else
    tickets = @client.search(:query => "type:ticket group_id:#{group_id} status:closed organization_id:none updated_at>=#{year}-01-01 updated_at<#{year+1}-01-01").count.to_i
  end
  total_tickets += tickets
  puts year.to_s+","+tickets.to_s
  year += 1
end

puts "Total deletable tickets: #{total_tickets}"