#!/bin/bash

# define the variables
DIRECTORY=$1
HERE=$(pwd)

# move to the directory
cd $DIRECTORY

# filter out 'name' data from our data
cat ./*/failed_login_data.txt | awk '{print $4}' > temptxt.txt

# sort and count name data
sort temptxt.txt | uniq -c | awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' > temp.html

# add header and footer
cat $HERE/html_components/username_dist_header.html temp.html $HERE/html_components/username_dist_footer.html > username_dist.html

# remove temp files
rm temptxt.txt
rm temp.html
