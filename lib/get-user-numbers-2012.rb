require 'zendesk_api'

require_relative 'zendesk_setup'
@client = create_zendesk_client_from_env(ENV)

#
# 2012
#

@y2012_users = []

search_results = @client.search(:query => "type:user created_at>=2012-01-01 created_at<2013-01-01 role:end-user -name:Zendesk organization_id:none")

# The Zendesk API has 100 items per page, so programatically
# determine how many pages we have by rounding to the nearest 100.
user_count =  search_results.count
number_of_pages = (user_count.to_f / 100).ceil

# Loop through users and write user IDs to file
(1..number_of_pages).each do |i|
  @client.search(:query => "type:user created_at>=2012-01-01 created_at<2013-01-01 role:end-user -name:Zendesk organization_id:none").page(i).each do |user|
    @y2012_users << user['id']
    puts user['id']
  end
end

File.open("data/y2012_users", "w") { |file| file.write(@y2012_users) }
