#!/bin/bash

# Setup the vars
input_path="./data/remote/users_deleted_confirmed/"
master_file=${input_path}users_to_purge

output_path=${input_path}ready_to_purge
output_prefix="purge."

# If the previous output dir exists, remove it
if [ -e $output_path ] ; then
    rm -rf ${output_path}
fi

# If the output dir does not exist, let's create it
if [[ ! -e $output_path ]]; then
    mkdir -p $output_path
fi

# If the previous master file exists, remove it
if [ -f $master_file ] ; then
    rm ${master_file}
fi

# Create CSV files
sort ${input_path}users_deleted* | uniq | tr "\n" "," | sed -e $'s/,/\\\n/g' >> ${master_file}

# Split master file into chunks so we can parallel-ise if possible, suffix=4, l=100lines, t=sep(,)
split -a 4 -l 100 -t, --numeric-suffixes=1 ${master_file} ${output_path}/${output_prefix}

# sed statement to create multiple line files, add after tr command above: | sed -e $'s/,/,\\\n/g'

