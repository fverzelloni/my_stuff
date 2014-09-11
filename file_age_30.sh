#!/bin/bash 

#Double check before remove files

GET_EPOC="stat -c %X"
DATE_EPOC=$(date +%s) 
DIFFERENCE=30


cat $1 | while read line ; 
do

RESULT=$(echo "($DATE_EPOC-$($GET_EPOC $line))/(3600*24)" | bc)
	if [ $RESULT -le 30 ] ;
		then
			echo "File $line is not older than 30 days!!!"
	fi
done
