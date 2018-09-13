#!/bin/bash

DIRECTORY=$1

HERE=$(pwd)

cd $DIRECTORY

cat ./*/failed_login_data.txt | awk '{print $3}' > temptxt.txt

sort temptxt.txt | uniq -c | awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' > temp.html

cat $HERE/html_components/hours_dist_header.html temp.html $HERE/html_components/hours_dist_footer.html > hours_dist.html

rm temptxt.txt
rm temp.html
