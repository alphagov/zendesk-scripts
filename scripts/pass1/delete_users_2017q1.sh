#!/bin/sh

# if [ "${DRY_RUN+1}" ] ; then
#   for raw_id in `cat data/y2012_tickets`
# 		do
# 			clean_id=`echo $raw_id | sed -e 's/\,//g' | sed -e 's/\]//g' | sed -e 's/\[//g'`
# 			echo "*** DRY_RUN TICKET ID = $clean_id ***"
# 			echo "curl $ZENDESK_URL/tickets/$clean_id -v -u $ZENDESK_USER_EMAIL:ZENDESK_USER_PASSWORD -X DELETE"
# 		done

# else

year=2017q1
last_login=""
mv data/users_deleted_null_login_$year data/users_deleted_null_login_$year.bak
mv data/users_not_deleted_$year data/users_not_deleted_$year.bak

	for raw_id in `cat data/y${year}_users`
		do
			clean_id=`echo $raw_id | sed -e 's/\,//g' | sed -e 's/\]//g' | sed -e 's/\[//g'`
			echo "User ID:$clean_id"
			
			last_login=`curl $ZENDESK_URL/users/$clean_id -u $ZENDESK_USER_EMAIL:$ZENDESK_USER_PASSWORD | jq '.user.last_login_at'`

			if [ $last_login == "null" ] ; then

				echo "ID:$clean_id last_login is null, deleting it"
				echo "curl $ZENDESK_URL/users/$clean_id -v -u $ZENDESK_USER_EMAIL:$ZENDESK_USER_PASSWORD -X DELETE"
				curl $ZENDESK_URL/users/$clean_id -u $ZENDESK_USER_EMAIL:$ZENDESK_USER_PASSWORD -X DELETE

				echo $clean_id >> data/users_deleted_null_login_$year

			else
				echo "ID:$clean_id last_login:$last_login is not null, saving it"
				echo "$clean_id, $last_login" >> data/users_not_deleted_$year

			fi
			
			echo "-------------------------------------------------"
		done
# fi
