# Zendesk GDPR Cleaner and Manual Scripts

A collection of scripts and pipelines to locate and remove legacy Zendesk tickets and user accounts to meet GDPR

#### Zendesk Notes

* User account status can be either active, soft deleted or hard deleted.
* Accounts must be soft deleted before being hard deleted - i.e. 2 stages.
* Soft deleting sets field Active: FALSE
* Hard deleting removes all PII data but leaves the record and ID in the DB. (as a result, there are >1.2 million records available via the deleted users endpoint).
* Tickets should be removed BEFORE user accounts are addressed.

#### Zendesk parameters to ensure GDPR compliance

#### Tickets and User Accounts:

* Field "organization_id": null
* Field "updated_at" > 1 year ago when scripts run


#### User Accounts

* Field "role": "end-user"
* Field "name" [not = zendesk]
* No. of tickets belonging to user = 0


## Getting Started

* These instructions will get the project up and running on your local machine for development and testing purposes.
* It is highly recommended that an AWS VM is used for the longer manual scripted tasks.
* You will require a Zendesk account which has 'admin' privileges and an associated token.
* Use of linux 'screen' command is highly recommended
* Postman has proved very useful for developing and testing queries


## Environment variables

* ZENDESK_USER_EMAIL
* ZENDESK_URL
* ZENDESK_TOKEN
* ZENDESK_USER_PASSWORD (Only required if token not available)
* OUTPUT_TO_CONSOLE (Set to true if you want to see the output of 'user-ids-autom8-able.rb')

The Zendesk account email address and password are stored in [re-secrets](https://github.com/alphagov/re-secrets/) because together they have hard deletion capability in many ticket / user groups.

## Pipelines

Theses scripts are run periodically each night by Github Actions.

The pipelines are located under `./github/workflows/*`

[Deduplicator Script](https://github.com/alphagov/zendesk-scripts/actions/workflows/zendesk_deduplicator.yml)
[Ticket & User Tidier](https://github.com/alphagov/zendesk-scripts/actions/workflows/zendesk_remove_tickets_users.yml)


## Using the scripts (principally to address historic records in large datasets)


### Install ruby

Install ruby and gems

```
gem install bundler
cd zendesk-scripts
bundle install
```


### Add environmental variables to .bashrc or to 'screen' session

```
# Vars for Zendesk
export ZENDESK_USER_EMAIL=[zendesk admin-user email address]
export ZENDESK_USER_PASSWORD=[zendesk admin-user password]
export ZENDESK_URL=https://govuk.zendesk.com/api/v2
export ZENDESK_TOKEN=[token-string]
export ZENDESK_LOG_FILE=zendesk-GDPR-users-log.`date +%Y-%m-%d`
```

Start a 'screen' session and export vars, e.g.

```
screen -S "tickets"
export ZENDESK_USER_EMAIL=firstname.surname@digital.cabinet-office.gov.uk ; export ZENDESK_URL=https://govuk.zendesk.com/api/v2 ; export ZENDESK_USER_PASSWORD=[admin user password]
```


### Example Historical Ticket Processes

#### Retrieve and delete latest matching tickets (upto 364 days ago - date chosen to maintain GDPR for 24 hours rather than only for current moment)


```
screen -rd tickets       # Join existing screen session with vars exported and pwd=~ubuntu/zendesk-scripts.

bundle exec ruby lib/get-latest-ticket-numbers.rb
scripts/delete_latest_tickets.sh tee data/`tickets-date "+%FT%H:%M"`.log
```

Notes
* Retrieve the GDPR-outstanding tickets to [pwd]/data/latest-tickets-to-purge] and then delete them.
* The scripts should be run inside a screen session.
* Auth can take the form of user/password or user/token.
* Deletion can take several hours (for e.g. 50,000 tickets) depending on quantities.
* Check your API limitations, ours are currently 700 requests / minute for ticket deletion, 70/min for user account hard deletion.



#### Counting tickets


```
bundle exec ruby lib/count-closed-tickets-by-year.rb
```


#### Removing historical tickets (once only, kept for reference)

* Retrieve to local files in /data directory per year of ticket_id's

```
bundle exec ruby lib/get-annual-ticket-numbers.rb
```

* Results

Files are created per year, e.g.

```data/y2013_tickets```


* Execute script per year to delete old tickets (uses above files as input)

```
data/delete_tickets_2013.sh
```

* Suggestion: Exit the 'screen' session but leave the script running



### Example User Processes


#### Retrieve list of deleted user accounts to local file (note: includes hard deleted so may take several hours)


```
bundle exec ruby lib/get-deleted-user-ids-to_local-file.rb

```

#### Hard delete (purge) qualifying accounts (may take many hours due to lower API rate)


```
bundle exec ruby lib/purge-users-using-local-file.rb | tee data/`date --iso-8601='date'`.log
```
```
bundle exec ruby lib/count-closed-tickets-by-year.rb
bundle exec ruby lib/get-latest-ticket-numbers.rb
```

Notes
* The process must be to soft delete and then hard delete.
* When retrieving the accounts, previously hard deleted accounts are included with soft deleted, making the sift of data a large task.


#### Count User accounts

```
bundle exec ruby lib/count-users-by-year-for-deletion.rb
```

#### Create groups (json and text)

json
```
curl $ZENDESK_URL/groups.json -v -u "$ZENDESK_USER_EMAIL/token:$ZENDESK_TOKEN" > data/groups.json
```

text
```
bundle exec ruby lib/get-groups-list-to-file.rb
```

#### Create custom_roles (json and text)

json
```
curl $ZENDESK_URL/custom_roles.json -v -u "$ZENDESK_USER_EMAIL/token:$ZENDESK_TOKEN" > data/custom_roles.json
```

text
```
bundle exec ruby lib/get-custom-roles-list-to-file.rb
```

#### Retrieve Agents
```
bundle exec ruby lib/get-all-agents.rb > data/agents.json
```

#### Select and convert json to csv
```
jq -r '.name + "," + .role + "," + (.default_group_id|tostring) + "," + (.active|tostring) + "," + (.custom_role_id|tostring)' data/agents.json > data/agents.csv
```

#### Merge Agent and Group Description
```
sh scripts/merge-agent-and-group-description.sh
```

### Other Scripts

#### De-duplicate support queue
* The script uses the Zendesk API to identify multiple tickets from the same UserID in the 1st line support queue which match a set of parameters. If there are > 1 tickets with a status of not closed or solved, they are moved to a dedicated Zendesk queue.
* The script requires sufficient permissions in Zendesk and is configured to use an account email address and an API token for authenticating API requests.

To use the script from the CLI, set the environment variables as [above](#add-environmental-variables-to-bashrc-or-to-screen-session), then:

1. Edit window required (e.g. 24 hours) in this line, e.g.:
```
window_start_time = Time.now - 24 * 3600
```
2. Execute script
```
bundle exec ruby lib/zendesk-ticket-deduplicator.rb
```

##### Important Notes

* This pipeline should only run 6 hourly in order to mesh with the manual processes carried out by the support team. If updating the code, please pause the pipeline before merging to ensure it does not run between the 6 hour windows.
* Running outside of the schedule may cause tickets to be moved around unexpectedly during the hours people are working on them.


## License

This project is licensed under the MIT License
