# Usage - call script with bundle exec ruby lib/get-all-agents.rb

require 'zendesk_api'
require 'rest-client'
require 'json'

require_relative 'zendesk-setup.rb'

# Usage: bundle exec ruby lib/get-all-agents.rb > data/agents.json

search_results = @client.search(:query => "type:user role:agent organization_id:21891972")

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