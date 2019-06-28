require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end

#
# 2012
#

@y2012_users = []

(1..140).each do |i|
  @client.search(:query => "type:user created_at>2012-01-01 created_at<2013-01-01 role:end-user -name:Zendesk organization_id:none").page(i).each do |user|
    @y2012_users << user['id']
    puts user['id']
  end
end

File.open("data/y2012_users", "w") { |file| file.write(@y2012_users) }
