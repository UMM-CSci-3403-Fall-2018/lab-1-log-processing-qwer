#!/bin/bash

DIRECTORY=$1

HERE=$(pwd)

cd $DIRECTORY

cat country_dist.html hours_dist.html username_dist.html > temp.html

$HERE/bin/wrap_contents.sh temp.html $HERE/html_components/summary_plots failed_login_summary.html

rm temp.html
