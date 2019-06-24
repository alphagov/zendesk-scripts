#!/bin/sh

if ! [ "${DRY_RUN+1}" ] ; then
  for raw_id in `cat data/y2015_tickets`
		do
			clean_id=`echo $raw_id | sed -e 's/\,//g' | sed -e 's/\]//g' | sed -e 's/\[//g'`
			echo "*** DRY_RUN TICKET ID = $clean_id ***"
			echo "curl $ZENDESK_URL/tickets/$clean_id -v -u $ZENDESK_USER_EMAIL:ZENDESK_USER_PASSWORD -X DELETE"
		done

else

	for raw_id in `cat data/y2015_tickets`
		do
			clean_id=`echo $raw_id | sed -e 's/\,//g' | sed -e 's/\]//g' | sed -e 's/\[//g'`
			curl $ZENDESK_URL/tickets/$clean_id -v -u $ZENDESK_USER_EMAIL:$ZENDESK_USER_PASSWORD -X DELETE
		done
fi