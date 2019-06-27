require 'zendesk_api'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end

#
# 2017 Q2
#

@y2017q2_users = []

(1..1500).each do |i|
  @client.search(:query => "type:user created_at>2017-04-01 created_at<2017-07-01 role:end-user -name:Zendesk organization_id:none").page(i).each do |user|
    @y2017q2_users << user['id']
    puts user['id']
  end
end

File.open("data/y2017q2_users", "w") { |file| file.write(@y2017q2_users) }
