require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end


#
# 2018PO
#

@y2018_tickets = []

#
puts "Total Tickets 2018 to 23 June"
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2018-01-01 updated_at<2018-06-23").count

(1..1000).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2018-01-01 updated_at<2018-06-23").page(i).each do |ticket|
    @y2018_tickets << ticket['id']
  end
end

File.open("data/y2018_tickets", "w") { |file| file.write(@y2018_tickets) }

exit
