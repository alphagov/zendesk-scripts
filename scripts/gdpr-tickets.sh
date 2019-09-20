#!/bin/bash

export ZENDESK_USER_EMAIL=david.pye@digital.cabinet-office.gov.uk
export ZENDESK_URL=https://govuk.zendesk.com/api/v2
export ZENDESK_USER_PASSWORD=Tcs1415926535

export ZENDESK_HOME=/home/ubuntu/zendesk-scripts

cd $ZENDESK_HOME

# get latest deleted ticket IDs to file
echo "Retrieving ticket IDs to file"
bundle exec ruby lib/get-latest-ticket-numbers.rb

# delete tickets from file above
echo "Deleting closed tickets within agreed parameters"
scripts/delete_latest_tickets.sh | tee data/`tickets-date --iso-8601='date'`.log
