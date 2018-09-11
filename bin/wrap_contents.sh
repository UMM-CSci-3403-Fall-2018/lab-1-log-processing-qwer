#!/bin/bash

#file containing constants to be wrapped
file=$1
#name of specified header and footer(*_footer.html, *_header.html)
bits=$2
#name of resulting file
result=$3

cat ${bits}_header.html $file ${bits}_footer.html > $result
