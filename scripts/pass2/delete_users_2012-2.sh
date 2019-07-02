#!/bin/bash

year=2012
last_login=2018
last_login1=$((last_login+1))


while IFS=, read -r col1 col2
do
  clean_id=$col1
  login_year=$( echo "$col2" | sed 's/"//g' | cut -d"-" -f1 )

  if [ $login_year != $last_login ]; then #not 2018

    if [ $login_year != $last_login1 ]; then #not 2018 or 2019
      curl $ZENDESK_URL/users/$clean_id -v -u $ZENDESK_USER_EMAIL:$ZENDESK_USER_PASSWORD -X DELETE
      echo $clean_id >> data/users_deleted_null_login_${year}_pass2
    else
      echo "2019 detected"
      echo "$clean_id, $col2" >> data/users_not_deleted_${year}
    fi
  else
    echo "2018 detected"
    echo "$clean_id, $col2" >> data/users_not_deleted_${year}
  fi
done < data/remote/users_not_deleted_${year}
