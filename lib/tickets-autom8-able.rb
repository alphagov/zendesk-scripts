require 'zendesk_api'

require_relative 'zendesk_setup'

today = Date.today
lastyear = Date.today.next_day - 365
directory = "data/all_groups"
directory_name = "#{directory}-#{today}"

Dir.mkdir(directory_name) unless File.exists?(directory_name)

# get groups, so we are future proof
groups_list = @client.groups

groups_list.each do |group|
  group_id = group.id
  tickets = []
  ticket_count_for_period = 0

  ticket_count_for_period = @client.search(:query => "type:ticket group:#{group_id} organization:none status:closed updated>=2012-01-01 updated<#{lastyear}").count.to_i
  puts "Deletable Tickets for Group: #{group_id} : #{ticket_count_for_period}"
  
  if ticket_count_for_period != 0
    # calcuate no. of pages @ 100 items/page
    number_of_pages = (ticket_count_for_period.to_f / 100).ceil + 1

    (1..number_of_pages).each do |i|
      @client.search(:query => "type:ticket group:#{group_id} organization:none status:closed updated>=2012-01-01 updated<#{lastyear}").page(i).each do |ticket|
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

# loop through tickets in each group file and delete
# log_file copied to S3 bucket outside ruby script

filenames = Dir.children(directory_name)
log_file_name = ENV['ZENDESK_LOG_FILE']

File.open(log_file_name, "w") {|log_file|
  filenames.each do |file|
    File.open("#{directory_name}/#{file}").each do |ticket_id|
      message = "Deleting Ticket: #{ticket_id.gsub("\n", '')} from Group: #{file}"
      puts message
      log_file.puts message
      @client.tickets.destroy!(:id => ticket_id.to_i)
    end
  end
}
puts "- - - - Zendesk Ticket deletion has completed - - - -"