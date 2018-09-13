#!/bin/bash

# define variables
FILES=$@
HERE=$(pwd)

# make temp directory
mkdir tmp
mkdir tmp/tmp_logs

# extraction for loop (I am using a stupid method but it works LOL)
for f in $FILES
do
    FILE="$(basename -s .tgz $f)"
    mkdir tmp/tmp_logs/$FILE
    tar -xzvf $f -C tmp/tmp_logs/$FILE
    bin/process_client_logs.sh tmp/tmp_logs/$FILE
done

# call previous helper functions
bin/create_username_dist.sh tmp/tmp_logs
bin/create_hours_dist.sh tmp/tmp_logs
bin/create_country_dist.sh tmp/tmp_logs
bin/assemble_report.sh tmp/tmp_logs

# move our html file to the top directory
mv tmp/tmp_logs/failed_login_summary.html $HERE

# remove temp directory
rm -r tmp
