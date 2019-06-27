require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end

today = Date.today.prev_day
lastyear = today - 365

#  puts "Total Tickets: #{@client.users.count}"

puts "Total Users 2012"
puts @client.search(:query => "type:user created_at>2012-01-01 created_at<2013-01-01 role:end-user -name:Zendesk organization_id:none").count
puts "Total Users 2013"
puts @client.search(:query => "type:user created_at>2013-01-01 created_at<2014-01-01 role:end-user -name:Zendesk organization_id:none").count
puts "Total Users 2014"
puts @client.search(:query => "type:user created_at>2014-01-01 created_at<2015-01-01 role:end-user -name:Zendesk organization_id:none").count
puts "Total Users 2015"
puts @client.search(:query => "type:user created_at>2015-01-01 created_at<2016-01-01 role:end-user -name:Zendesk organization_id:none").count
puts "Total Users 2016"
puts @client.search(:query => "type:user created_at>2016-01-01 created_at<2017-01-01 role:end-user -name:Zendesk organization_id:none").count
puts "Total Users 2017 Q1"
puts @client.search(:query => "type:user created_at>2017-01-01 created_at<2017-04-01 role:end-user -name:Zendesk organization_id:none").count
puts "Total Users 2017 Q2"
puts @client.search(:query => "type:user created_at>2017-04-01 created_at<2017-07-01 role:end-user -name:Zendesk organization_id:none").count
puts "Total Users 2017 Q3/4"
puts @client.search(:query => "type:user created_at>2017-07-01 created_at<2018-01-01 role:end-user -name:Zendesk organization_id:none").count
puts "Total Users 2018 to 23 Jun"
puts @client.search(:query => "type:user created_at>2018-01-01 created_at<2018-06-23 role:end-user -name:Zendesk organization_id:none").count

#  last_login_at:none