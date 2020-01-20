#!/bin/bash

agents_in="data/agents.csv"
groups_in="data/groups.json"
agents_and_groups="data/agents-and-groups.csv"
mv ${agents_and_groups} ${agents_and_groups}.bak

while IFS= read -r agent
do
  # echo "agent=${agent}"
  group_id=`echo ${agent} | cut -d "," -f3`
  # echo "group_id=${group_id}"
  group_txt=`grep ${group_id} ${groups_in} | cut -d "," -f2`
  # echo "group_txt=${group_txt}"
  echo ${agent},${group_txt} >> ${agents_and_groups}
  sort -t "," -k2  ${agents_and_groups} > ${agents_and_groups}.sorted

done < ${agents_in}