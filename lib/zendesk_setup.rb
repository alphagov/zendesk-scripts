require 'zendesk_api'

def create_zendesk_client_from_env(environment)
  ZendeskAPI::Client.new do |config|
    config.url = environment['ZENDESK_URL']
    config.username = environment['ZENDESK_USER_EMAIL']
    config.token = environment['ZENDESK_TOKEN']
    config.retry = true
  end
end
