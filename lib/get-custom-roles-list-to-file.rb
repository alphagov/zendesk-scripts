require 'date'
require 'json'
require 'zendesk_api'

require_relative 'zendesk_setup'

output_file = "data/custom-roles.out"

File.open(output_file, "w") do |file|

  custom_roles_list = @client.custom_roles

  custom_roles_list.each do |role|
    role_id = role.id
    role_name = role.name
    role_desc = role.description

    file.write("#{role_id},#{role_name},#{role_desc}\n")
  end
end
