#!/bin/bash

# Requires
# data/groups.out
# data/custom-roles.out

agents_in="data/agents.csv"
custom_roles="data/custom-roles.out"
groups_in="data/groups.out"
agents_and_groups="data/agents-and-groups.csv"

if [ -f ${agents_and_groups} ]
  then mv ${agents_and_groups} ${agents_and_groups}.bak
fi

echo "Name,Role,Default_Group,Active,Custom_Role_ID,Group_Description,Custom_Role_Description" > ${agents_and_groups}

while IFS= read -r agent
do
  group_id=`echo ${agent} | cut -d "," -f3`
  group_txt=`grep ${group_id} ${groups_in} | cut -d "," -f2`
  custom_role_id=`echo ${agent} | cut -d "," -f5`
  custom_role_text=`grep ${custom_role_id} ${custom_roles} | cut -d "," -f2`
  echo ${agent},${group_txt},${custom_role_text} >> ${agents_and_groups}

done < ${agents_in}