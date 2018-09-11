#!bin/bash

directory=$1

cd $directory

cat *.tgz | awk 'BEGIN{FS="|"} $1 == "Failed password" { print NR " " $1 " " $2 " " $3 " " $9 " " $11}' 
