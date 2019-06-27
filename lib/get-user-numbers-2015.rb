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

@y2015_users = []

(1..925).each do |i|
  @client.search(:query => "type:user created_at>2015-01-01 created_at<2016-01-01 role:end-user -name:Zendesk organization_id:none").page(i).each do |user|
    @y2015_users << user['id']
    puts user['id']
  end
end

File.open("data/y2015_users", "w") { |file| file.write(@y2015_users) }
