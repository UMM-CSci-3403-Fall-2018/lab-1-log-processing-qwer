#!/bin/bash

# define the variables
DIRECTORY=$1
HERE=$(pwd)

# move to the directory
cd $DIRECTORY

# filter out 'hours' data from our data
cat ./*/failed_login_data.txt | awk '{print $3}' > temptxt.txt

# make target html files
sort temptxt.txt | uniq -c | awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' > temp.html

# add header and footer
cat $HERE/html_components/hours_dist_header.html temp.html $HERE/html_components/hours_dist_footer.html > hours_dist.html

# remove temp files
rm temptxt.txt
rm temp.html
