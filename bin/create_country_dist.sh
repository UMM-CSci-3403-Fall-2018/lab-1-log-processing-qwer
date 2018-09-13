#!/bin/bash

DIRECTORY=$1

HERE=$(pwd)

cd $DIRECTORY

cat ./*/failed_login_data.txt | awk '{print $5}' | sort > tempip.txt

join tempip.txt $HERE/etc/country_IP_map.txt | awk '{print $2}' | sort | uniq -c | awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' > tempcountry.html

cat $HERE/html_components/country_dist_header.html tempcountry.html $HERE/html_components/country_dist_footer.html > country_dist.html

rm tempip.txt
rm tempcountry.html


