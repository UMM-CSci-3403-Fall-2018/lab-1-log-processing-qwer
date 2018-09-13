#!/bin/bash

# define the variables
DIRECTORY=$1
HERE=$(pwd)

# move to the directory
cd $DIRECTORY

# filter out 'ip' data from our data and sort it
cat ./*/failed_login_data.txt | awk '{print $5}' | sort > tempip.txt

# map ip address with country name
join tempip.txt $HERE/etc/country_IP_map.txt | awk '{print $2}' | sort | uniq -c | awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' > tempcountry.html

# make html file with its header and footer
cat $HERE/html_components/country_dist_header.html tempcountry.html $HERE/html_components/country_dist_footer.html > country_dist.html

# remove temp files
rm tempip.txt
rm tempcountry.html


