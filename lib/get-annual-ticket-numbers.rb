require 'zendesk_api'

if ARGV[0].nil? || ARGV[1].nil?
  puts "Specify a year to delete as an argument (eg 2012)"
  puts "Specify a queue (aka group) as an argument after the year to delete"
  exit(1)
else
  @year_to_delete = ARGV[0].to_i
  @queue = ARGV[1].to_i
end

@client = ZendeskAPI::Client.new do |config|
  config.url = ENV['ZENDESK_URL']
  config.username = ENV['ZENDESK_USER_EMAIL']
  config.password = ENV['ZENDESK_USER_PASSWORD']

  config.retry = true
end

puts "Total tickets overall: #{@client.tickets.count}"

ticket_count_for_year = @client.search(:query => "type:ticket group_id:#{@queue} status:closed updated_at>#{@year_to_delete}-01-01 updated_at<#{@year_to_delete + 1}-01-01").count

# The Zendesk API has 100 tickets per page, so programatically
# determine how many pages we have by rounding to the nearest 100.
number_of_pages = (ticket_count_for_year.to_f / 100).ceil

@tickets = []

(1..number_of_pages).each do |i|
  @client.search(:query => "type:ticket group_id:#{@queue} status:closed updated_at>#{@year_to_delete}-01-01 updated_at<#{@year_to_delete + 1}-01-01").page(i).each do |ticket|
    @tickets << ticket['id']
  end
end

File.open("data/y#{@year_to_delete}_tickets", "w") { |file| file.write(@tickets) }
