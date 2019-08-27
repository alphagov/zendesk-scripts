# Usage - call script with bundle exec ruby lib/get-all-user-account-to_local-file-ok.rb | tee /Users/davidpye/alphagov/zendesk-scripts/data/users-to-delete.jsonl
# above file path used in deletion step.

require 'zendesk_api'
require 'rest-client'
require 'json'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']
  config.retry = true
end

# day = Date.today.prev_day
# lastyear = day - 365
# puts "last year:#{lastyear}"

# begin
#   search_results = RestClient::Request.execute method: :get, url: "#{ENV['ZENDESK_URL']}/deleted_users.json", user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD']
# rescue RestClient::ExceptionWithResponse => err
#   err.response
# end

# TBC NEED TO LIMIT THE DATE RANGE AS 8000+ PAGES CURRENTLY!!!

begin
  url = "https://govuk.zendesk.com/api/v2/deleted_users.json"
  output_results = []
  while url do
    search_results = JSON.parse(RestClient::Request.execute method: :get, url: url, user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD'])
    output_results << search_results
    puts search_results['next_page']
    # puts "output_results: #{output_results}"
    url = search_results['next_page']
  end
end

File.open("data/soft_deleted_users", "w") { |file| file.write(output_results) }



# The Zendesk API has 100 items per page, so programatically
# determine how many pages we have by rounding to the nearest 100.

# puts err.response


# user_count =  search_results.length
# number_of_pages = (user_count.to_f / 100).ceil

# # For diagnosis

# puts "User Accounts: #{user_count}"
# puts "Pages of Users: #{number_of_pages}"

# # Loop through users matching criteria and 2 stage delete (soft then hard)
# (1..number_of_pages).each do |i|
#   search_results.page(i).each do |user|
#   puts user.to_json
#   end
# end