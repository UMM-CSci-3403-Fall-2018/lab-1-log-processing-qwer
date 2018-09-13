#!/bin/bash

# define variables
DIRECTORY=$1
HERE=$(pwd)

# move to the target directory
cd $DIRECTORY

# combine dists together
cat country_dist.html hours_dist.html username_dist.html > temp.html

# use wrap_contents to create the failed_login_summary file
$HERE/bin/wrap_contents.sh temp.html $HERE/html_components/summary_plots failed_login_summary.html

# delete the temp file
rm temp.html
