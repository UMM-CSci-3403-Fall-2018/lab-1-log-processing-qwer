#!/bin/bash

DIRECTORY=$1

cd $DIRECTORY

cd var

cd log

cat * | awk '/Failed password for invalid user/ {print " " $1 " " $2 " " substr($3, 0, 2) " " $11 " " $13}' | cat > ../../failed_login_data.txt

cat * | awk '/Failed password/ && !/invalid/ {print " " $1 " " $2 " " substr($3, 0, 2) " " $9 " " $11}' | cat >> ../../failed_login_data.txt
