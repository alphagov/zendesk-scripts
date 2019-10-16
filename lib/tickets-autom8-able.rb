require 'zendesk_api'

require_relative 'zendesk-setup.rb'

today = Date.today
directory = "data/all_groups"
lastyear = Date.today.prev_day - 365
directory_name = "#{directory}-#{today}"

Dir.mkdir(directory_name) unless File.exists?(directory_name)

# get groups, so we are future proof
groups_list = @client.groups

groups_list.each do |group|
  group_id = group.id
  tickets = []
  ticket_count_for_period = 0

  ticket_count_for_period = @client.search(:query => "type:ticket group_id:#{group_id} organization_id:none status:closed updated_at>=2012-01-01 updated_at<#{lastyear}").count.to_i
  puts "Deletable Tickets for Group: #{group_id} : #{ticket_count_for_period}"
  
  if ticket_count_for_period != 0
    # calcuate no. of pages @ 100 items/page
    number_of_pages = (ticket_count_for_period.to_f / 100).ceil + 1

    (1..number_of_pages).each do |i|
      @client.search(:query => "type:ticket group_id:#{group_id} organization_id:none status:closed updated_at>=2012-01-01 updated_at<#{lastyear}").page(i).each do |ticket|
        tickets << ticket['id']
      end
    end

    File.open("#{directory_name}/#{group_id}", "w") do |file|
      tickets.each do |ticket|
        file.write("#{ticket}\n")
      end
    end  
  end
end

# Delete tickets returned

filenames = Dir.children(directory_name)

# loop through tickets in file and delete

filenames.each do |file|
  File.open("#{directory_name}/#{file}").each do |ticket_id|
    puts "Deleting Ticket: #{ticket_id}"
    @client.tickets.destroy!(:id => ticket_id.to_i)
  end
end