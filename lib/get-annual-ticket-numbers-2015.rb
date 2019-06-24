require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end


#
# 2015
#

@y2015_tickets = []

#
puts "Total Tickets 2015"
#

puts @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2015-01-01 updated_at<2016-01-01").count

(1..1000).each do |i|
  @client.search(:query => "type:ticket group_id:20188163 status:closed updated_at>2015-01-01 updated_at<2016-01-01").page(i).each do |ticket|
    @y2015_tickets << ticket['id']
  end
end

File.open("data/y2015_tickets", "w") { |file| file.write(@y2015_tickets) }


exit
