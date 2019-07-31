require 'zendesk_api'
require 'rest-client'
require 'json'
require 'date'

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']
  config.retry = true
end

# Setup Date related vars

day = Date.today.next_day
lastyear = day - 365
false_date = "2012-01-01"

# Initialise input file

input_file = "data/users-to-delete-TEST.jsonl"

# puts Dir.pwd

# Read from the file
# file contains user accounts selected using
# search(:query => "type:user created_at<#{lastyear} updated_at<#{lastyear} role:end-user -name:Zendesk organization_id:none")
# so we only need to check last_login_at and no. of tickets > 0

# This works for single line test file
# file = File.open input_file
# file_data = JSON.load file
# file.close


# json = JSON.parse(File.load("data/users-to-delete-TEST.jsonl"))

file_data = JSON.parse(File.read('data/users-to-delete.jsonl'))
file_data.each do |user|


  # Extract some fields

  updated_at = user["updated_at"]
  last_login_at = user["last_login_at"]
  user_id = user["id"]



  # Convert strings to dates, if strings are nil then set a false date of 2012 so comparison works.

  if updated_at != nil
    updated = Date.parse(updated_at)
  else
    updated_at = false_date
    updated = Date.parse(updated_at)
  end

  if last_login_at != nil
    last_login = Date.parse(last_login_at)
  else
    last_login_at = false_date
    last_login = Date.parse(last_login_at)
  end


  # diagnostics
  # puts "day: #{day}"
  # puts "lastyear: #{lastyear}"
  # puts "user_id: #{user_id}"
  # puts "file_data: #{file_data}"
  # puts "updated_at: #{updated_at}"
  # puts "updated: #{updated}"
  # puts "last_login_at: #{last_login_at}"
  # puts "last_login: #{last_login}"

  # If last logged in < last year, let's check whether user has any tickets associated

  if last_login <= lastyear
    puts "DELETE candidate - check tickets"
    count = @client.search!(:query => "requester_id:#{user_id}").count
    ticket_count = Integer count
    puts "ticket_count: #{ticket_count}"
  else
    puts "DO NOT DELETE"
  end

  if ticket_count == 0
    puts "ok we're ready, DELETE this user: #{user_id}"
    # soft delete
    @client.users.destroy!(:id => user_id)
    # api does not support hard delete yet, so...
    RestClient::Request.execute method: :delete, url: "#{ENV['ZENDESK_URL']}/deleted_users/#{user_id}.json", user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD']
  else
    puts "not deleting #{user_id}"
  end
end

#   ticket_count = RestClient::Request.execute method: :get, url: "#{ENV['ZENDESK_URL']}/search.json?query=#{user_id}", user: ENV['ZENDESK_USER_EMAIL'], password: ENV['ZENDESK_USER_PASSWORD']
#   ticket_count =  @client.search(:query => "type:requestor_id:361789449539").count
#   ticket_count =  @client.tickets.find!(:id = 361789449539)


# for each field, loop through logic check
#   if field matches (ok to delete data)
#     delete

#   else
#     next field

# end

# example file data

# {"id":318287452,"url":"https://govuk.zendesk.com/api/v2/users/318287452.json","name":"Luke","email":"gobellsch@gmail.com","created_at":"2013-01-01 16:20:30 UTC","updated_at":"2013-01-01 16:20:30 UTC","time_zone":"London","iana_time_zone":"Europe/London","phone":null,"shared_phone_number":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null,"two_factor_auth_enabled":false,"signature":null,"details":null,"notes":null,"role_type":null,"custom_role_id":null,"moderator":false,"ticket_restriction":"requested","only_private_comments":false,"restricted_agent":true,"suspended":false,"chat_only":false,"default_group_id":null,"report_csv":false,"user_fields":{},"result_type":"user"}

# {
#   "id": 277278633,
#   "url": "https://govuk.zendesk.com/api/v2/users/277278633.json",
#   "name": "Paul Sawyer",
#   "email": "paul.sawyer@hertsmere.gov.uk",
#   "created_at": "2012-10-17 14:43:06 UTC",
#   "updated_at": "2012-10-17 14:43:06 UTC",
#   "time_zone": "London",
#   "iana_time_zone": "Europe/London",
#   "phone": null,
#   "shared_phone_number": null,
#   "photo": null,
#   "locale_id": 1,
#   "locale": "en-US",
#   "organization_id": null,
#   "role": "end-user",
#   "verified": false,
#   "external_id": null,
#   "tags": [],
#   "alias": null,
#   "active": true,
#   "shared": false,
#   "shared_agent": false,
#   "last_login_at": null,
#   "two_factor_auth_enabled": false,
#   "signature": null,
#   "details": null,
#   "notes": null,
#   "role_type": null,
#   "custom_role_id": null,
#   "moderator": false,
#   "ticket_restriction": "requested",
#   "only_private_comments": false,
#   "restricted_agent": true,
#   "suspended": false,
#   "chat_only": false,
#   "default_group_id": null,
#   "report_csv": false,
#   "user_fields": {},
#   "result_type": "user"
# }