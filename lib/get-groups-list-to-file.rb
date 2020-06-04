require 'date'
require 'json'
require 'zendesk_api'

require_relative 'zendesk_setup'

output_file = "data/groups.out"

File.open(output_file, "w") do |file|

  groups_list = @client.groups

  groups_list.each do |group|
    group_id = group.id
    group_name = group.name

    file.write("#{group_id},#{group_name}\n")
  end
end
