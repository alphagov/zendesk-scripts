# Usage - call script with bundle exec ruby lib/get-all-user-account-to_local-file-ok.rb | tee /Users/davidpye/alphagov/zendesk-scripts/data/users-to-delete.jsonl
# above file path used in deletion step.

require 'zendesk_api'
require 'rest-client'
require 'json'

require_relative 'zendesk_setup'
@client = create_zendesk_client_from_env(ENV)

# TODO LIMIT THE DATE RANGE AS 8000+ PAGES CURRENTLY!!!

begin
  url = "https://govuk.zendesk.com/api/v2/deleted_users.json"
  output_results = []
  while url do
    search_results = JSON.parse(RestClient::Request.execute method: :get, url: url, user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD'])
    (output_results << search_results['deleted_users']).flatten!
    puts search_results['next_page']
    url = search_results['next_page']
  end
end

File.open("data/soft_deleted_users.json", "w") { |file| file.write(JSON.generate(output_results)) }