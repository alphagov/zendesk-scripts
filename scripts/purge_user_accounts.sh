#!/bin/bash

# Expects the following env vars

# ZENDESK_USER_EMAIL=blah@digital.cabinet-office.gov.uk
# ZENDESK_URL=https://govuk.zendesk.com/api/v2
# ZENDESK_USER_PASSWORD=password-here-please

# Laptop source: input_file="/Users/davidpye/alphagov/zendesk-scripts/data/remote/users_deleted_confirmed/users_to_purge"
input_file="/home/ubuntu/zendesk-scripts/data/remote/users_deleted_confirmed/users_to_purge"
# test_input_file="/Users/davidpye/alphagov/zendesk-scripts/data/remote/users.test"

for id in `cat ${input_file}`
do
	echo "Purging user account: ${id}"
	echo " "
  curl $ZENDESK_URL/deleted_users/${id}.json -u $ZENDESK_USER_EMAIL:$ZENDESK_USER_PASSWORD -X DELETE
#  sleep 1
	echo " "
	echo "-----------------------------------------------------------------"
	echo " "
done