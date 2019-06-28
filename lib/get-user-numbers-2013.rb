require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end

#
# 2013
#

@y2013_users = []

(1..708).each do |i|
  @client.search(:query => "type:user created_at>2013-01-01 created_at<2014-01-01 role:end-user -name:Zendesk organization_id:none").page(i).each do |user|
    @y2013_users << user['id']
    puts user['id']
  end
end

File.open("data/y2013_users", "w") { |file| file.write(@y2013_users) }
