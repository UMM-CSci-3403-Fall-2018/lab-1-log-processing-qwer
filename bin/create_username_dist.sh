#!/bin/bash

DIRECTORY=$1

HERE=$(pwd)

cd $DIRECTORY

sort ./*/failed_login_data.txt | uniq -c | awk '{print "data.addRow([\x27" $5 "\x27, " $1 "]);"}' > temp.html

cat $HERE/html_components/username_dist_header.html temp.html $HERE/html_components/username_dist_footer.html > username_dist.html

rm temp.html
