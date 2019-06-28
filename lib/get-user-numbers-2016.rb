require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end

#
# 2016
#

@y2016_users = []

(1..887).each do |i|
  @client.search(:query => "type:user created_at>2016-01-01 created_at<2017-01-01 role:end-user -name:Zendesk organization_id:none").page(i).each do |user|
    @y2016_users << user['id']
    puts user['id']
  end
end

File.open("data/y2016_users", "w") { |file| file.write(@y2016_users) }
