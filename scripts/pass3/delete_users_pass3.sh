#!/bin/bash

if [ $# -ne 1 ]; then
    echo $0: usage: delete_users year
    exit 1
fi


master_file=$1
# input_path="/Users/davidpye/alphagov/zendesk-scripts/data/remote/"
# master_file=${input_path}users_to_test_pass3

last_login=`date -I -d "364 days ago"`

while IFS=, read -r col1 col2
do
  clean_id=$col1
  login_date=$( echo "$col2" | cut -d, -f1 | sed 's/"//g' | cut -d"T" -f1 )

  if [ "$login_date" > "$last_login" ]; then
    echo "older than 1 year ago - DELETE CANDIDATE"
    curl $ZENDESK_URL/users/$clean_id -u $ZENDESK_USER_EMAIL:$ZENDESK_USER_PASSWORD -X DELETE
    echo "id: ${clean_id} login_date: ${login_date}"
    echo "------------------------------------------"
  else
    echo "newer than 1 year ago"
    echo "id: ${clean_id} login_date: ${login_date}"
    echo "------------------------------------------"
  fi
done < ${master_file}





# LEGACY CODE
# exit

#   if [ $login_year = "" ]; then
#     echo ${id} >> 

#   if [ $login_year != $last_login ]; then #not 2018

#     if [ $login_year != $last_login1 ]; then #not 2018 or 2019
#       curl $ZENDESK_URL/users/$clean_id -u $ZENDESK_USER_EMAIL:$ZENDESK_USER_PASSWORD -X DELETE
#       echo $clean_id >> data/users_deleted_null_login_${year}_pass2
#     else
#       echo "2019 detected"
#       echo "$clean_id, $col2" >> data/users_not_deleted_${year}
#     fi
#   else
#     echo "2018 detected"
#     echo "$clean_id, $col2" >> data/users_not_deleted_${year}
#   fi
# done < data/remote/users_not_deleted_${year}
