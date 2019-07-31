# Zendesk Scripts

A collection of manual tasks (which will be autom8ed) to locate and remove legacy Zendesk tickets and user accounts to meet GDPR

## Getting Started

* These instructions will get the project up and running on your local machine for development and testing purposes.
* It is highly recommended that an AWS VM is used for the longer tasks.
* You will require a Zendesk account which has 'admin' privileges.
* Use of linux 'screen' command is highly recommended

### Clone the repo

```
git clone git@github.com:alphagov/zendesk-scripts
```


### Installing ruby

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
```

Start a 'screen' session and export vars, e.g.

```
screen -S "tickets"
export ZENDESK_USER_EMAIL=firstname.surname@digital.cabinet-office.gov.uk ; export ZENDESK_URL=https://govuk.zendesk.com/api/v2 ; export ZENDESK_USER_PASSWORD=[admin user password]
```


### Ticket Processes

#### Retrieve and delete latest matching tickets (upto 364 days ago - date chosen to maintain GDPR for 24 hours rather than only for current moment)



```
screen -rd tickets       # Join existing screen session with vars exported and pwd=~ubuntu/zendesk-scripts.

bundle exec ruby lib/get-latest-ticket-numbers.rb
scripts/delete_latest_tickets.sh tee data/`tickets-date "+%FT%H:%M"`.log
```

Notes
* Retrieve the GDPR-outstanding tickets to [pwd]/data/latest-tickets-to-purge] and then delete them.
* The scripts should be run inside a screen session.
* Deletion can take several hours (for e.g. 50,000 tickets) depending on quantities.
* Check the API limitations, currently 700 requests / minute for ticket deletion, 70/min for user account hard deletion.



#### Count existing tickets


```
bundle exec ruby lib/count-closed-tickets-by-year.rb
```


#### Removing historical tickets (once only, kept for reference)

* Extract local files in /data directory per year of ticket_id's

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

* Exit the 'screen' session but leave the script running



### User Processes


#### Retrieve list of deleted user accounts to local file (note: includes hard deleted so may take several hours)


```
bundle exec ruby lib/get-deleted-user-ids-to_local-file.rb

```

#### Hard delete (purge) qualifying accounts (may take many hours due to lower API rate)


```
bundle exec ruby lib/purge-users-using-local-file.rb | tee data/`date --iso-8601='date'`.log
```
bundle exec ruby lib/count-closed-tickets-by-year.rb
bundle exec ruby lib/get-latest-ticket-numbers.rb


Notes
* User account status can be either active, soft deleted or hard deleted.
* The process must be to soft delete and then hard delete.
* When retrieving the accounts, previously hard deleted accounts are included with soft deleted, making the sift of data a large task.


#### Count User accounts

```
bundle exec ruby lib/count-users-by-year-for-deletion.rb
```


## Contributing

Suggested reading: [Good Contributing guide](https://gist.github.com/PurpleBooth/b24679402957c63ec426)



## Authors

* **Issy Long** - ruby consultancy and initial work
* **David Pye** - Refactor task into year chunks and some bashing, plus prepare for automation


## License

This project is licensed under the MIT License
