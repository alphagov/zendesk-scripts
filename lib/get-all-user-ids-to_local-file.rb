# Usage - call script with bundle exec ruby lib/get-all-user-account-to_local-file-ok.rb | tee /Users/davidpye/alphagov/zendesk-scripts/data/users-to-delete.jsonl
# above file path used in deletion step.

require 'zendesk_api'
require 'rest-client'
require 'json'

require_relative 'zendesk_setup'
@client = create_zendesk_client_from_env(ENV)

lastyear = Date.today.prev_day - 365
puts "last year:#{lastyear}"

# TODO LIMIT THE DATE RANGE AS 8000+ PAGES CURRENTLY!!!

search_results = @client.search(:query => "type:user role:end-user -name:Zendesk organization_id:none")

# The Zendesk API has 100 items per page, so programatically
# determine how many pages we have by rounding to the nearest 100.

user_count =  search_results.count
number_of_pages = (user_count.to_f / 100).ceil

# Loop through users matching criteria and 2 stage delete (soft then hard)
(1..number_of_pages).each do |i|
  search_results.page(i).each do |user|
    puts user.to_json
  end
end