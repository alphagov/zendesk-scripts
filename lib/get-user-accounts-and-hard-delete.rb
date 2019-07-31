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

user_count =  @client.search(:query => "type:user created_at<#{lastyear} updated_at<#{lastyear} role:end-user -name:Zendesk organization_id:none").count
number_of_pages = (user_count.to_f / 100).ceil

# For diagnosis

puts "User Accounts to remove: #{user_count}"
puts "Pages of Users to remove: #{number_of_pages}"

# Loop through users matching criteria and 2 stage delete (soft then hard)
(1..number_of_pages).each do |i|
  @client.search(:query => "type:user created_at<#{lastyear} updated_at<#{lastyear} role:end-user -name:Zendesk organization_id:none").page(i).each do |user|
    user_id = user['id']
    puts "user_id: #{user_id}"

    # Get user ticket count

    user_ticket_count = @client.search(:query => "type:ticket requester_id:#{user_id}").count
     # REF: https://govuk.zendesk.com/api/v2/search.json?query=type:ticket requester_id:362089876908
    
     puts "user_ticket_count: #{user_ticket_count}"

    if user_ticket_count == 0
      puts "User account has zero acitve tickets, deleting..."
      # Call ruby zendesk api to soft delete
      user.destroy!
      # api does not support hard delete yet, so...
      RestClient::Request.execute method: :delete, url: "#{ENV['ZENDESK_URL']}/deleted_users/#{user_id}.json", user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD']
    end
  end
end