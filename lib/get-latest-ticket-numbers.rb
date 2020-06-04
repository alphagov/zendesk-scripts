require 'zendesk_api'

require_relative 'zendesk_setup'

group_id = ENV['ZENDESK_GROUP']

diag = "false"

# year-364 days means we will delete 1 extra day and be compliant for 23:59:59h
# but then we will run again in 24h time

today = Date.today
lastyear = Date.today.prev_day - 365

@latest_tickets = []

ticket_count_for_year = @client.search(:query => "type:ticket group_id:#{group_id} organization_id:none status:closed updated_at>=2018-01-01 updated_at<#{lastyear}").count.to_i

if diag == "true"
  puts "Total Tickets 2018 to 1 year ago today: #{ticket_count_for_year}"
end

# The Zendesk API has 100 tickets per page, so programatically
# determine how many pages we have by rounding to the nearest 100.
number_of_pages = (ticket_count_for_year.to_f / 100).ceil + 1

(1..number_of_pages).each do |i|
  @client.search(:query => "type:ticket group_id:#{group_id} status:closed organization_id:none updated_at>=2018-01-01 updated_at<#{lastyear}").page(i).each do |ticket|
    @latest_tickets << ticket['id']
  end
end

File.open("data/latest-tickets-to-purge-#{today}", "w") { |file| file.write(@latest_tickets) }

exit
