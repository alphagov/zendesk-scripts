require 'zendesk_api'
require 'rest-client'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']
  config.retry = true
end

day = Date.today.prev_day
lastyear = day - 365

# The Zendesk API has 100 items per page, so programatically
# determine how many pages we have by rounding to the nearest 100.

ticket_count =  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2018-01-01 updated_at<#{lastyear}").count
number_of_pages = (ticket_count.to_f / 100).ceil

# For diagnosis

puts "Tickets to remove: #{ticket_count}"
puts "Pages of Tickets to remove: #{number_of_pages}"

# Loop through tickets matching criteria and 2 stage delete (soft then hard)

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2018-01-01 updated_at<#{lastyear}").count

(1..number_of_pages).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2018-01-01 updated_at<#{lastyear}").page(i).each do |ticket|
    ticket_id = ticket['id']
    puts "ticket_id: #{ticket_id}"

    # Call ruby zendesk api to delete

    RestClient::Request.execute method: :delete, url: "#{ENV['ZENDESK_URL']}/tickets/#{ticket_id}.json", user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD']

  end
end