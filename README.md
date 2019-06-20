# Zendesk Scripts

Series of tasks to locate and remove legacy zendesk tickets and users to meet GDPR

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

Clone the repo

```
git clone git@github.com:alphagov/zendesk-scripts
```


### Prerequisites

Use of linux 'screen' command is highly recommended

Use dry run for testing

```
export DRY_RUN=true
```

ruby setup

```
bundle exec rake -T 
```

Add environmental variables to .bashrc
```
# Vars for Zendesk
export ZENDESK_USER_PASSWORD=[zendesk admin-user password]
export ZENDESK_USER_EMAIL=[zendesk admin-user email address]
export ZENDESK_URL=https://govuk.zendesk.com/api/v2
```


## Testing

Set the DRY_RUN variable and execute the scripts as per live process.


## Process

Start a 'screen' session, e.g.

```
screen -S "delete tickets 2013"
```

### Tickets
* Extract local files in /data directory per year of ticket_id's

```
bundle exec ruby lib/get-annual-ticket-numbers.rb
```

####   Results

Files are created per year, e.g.

```data/y2013_tickets```


* Execute script per year to delete old tickets (uses above files as input)

```
data/delete_tickets_2013.sh
```

* Exit the session but leave the script running
```
 ctrl+a
 d
```

* To resume the session

```
screen -r [sessionname]
```



Notes
* The scripts should be run inside a screen session
* Deletion takes several hours (for e.g. 50,000 tickets) depending on quantities and no. of scripts executing in parallel
* Check the API limitations, currently 700 requests / minute


### Users
* Execute ruby script to remove selected users

tbd ???



## Contributing

Please read [???](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.



## Authors

* **Issy Long** - Initial ruby work
* **David Pye** - Refactor task into year chunks and some bashing


## License

This project is licensed under the MIT License

## Acknowledgments

