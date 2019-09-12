require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end

# year-364 days means we will delete 1 xtra day and be compliant for 23:59:59h
# but then we will run again in 24h time

today = Date.today.prev_day
lastyear = today - 365

@latest_tickets = []

#
puts "Total Tickets 2018 to 1 year ago today"
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2018-01-01 updated_at<#{lastyear}").count

ticket_count_for_year = @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2018-01-01 updated_at<#{lastyear}").count
# The Zendesk API has 100 tickets per page, so programatically
# determine how many pages we have by rounding to the nearest 100.
number_of_pages = (ticket_count_for_year.to_f / 100).ceil + 1

(1..number_of_pages).each do |i|
  # We use updated_at>2018 because we have removed ALL tickets before this date previously.
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2018-01-01 updated_at<#{lastyear}").page(i).each do |ticket|
    @latest_tickets << ticket['id']
  end
end

File.open("data/latest-tickets-to-purge", "w") { |file| file.write(@latest_tickets) }

exit
