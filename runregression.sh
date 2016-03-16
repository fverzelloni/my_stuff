#!/bin/bash

######################################
#
# v1.0 Run regression on list of nodes
#
######################################

REGRESSION="/apps/common/regression/dev/run_regression "
LIST=$(echo $2 | tr "," "\n")
if [ ! -d /tmp/regression ]; 
	then 
		mkdir /tmp/regression
else
	rm -rf /tmp/regression/regression_*
fi


for i in `echo $LIST`
do
# DEBUG MODE UNCOMMENT THE FOLLOW LINE AND COMMENT THE ONE AFTER
#echo "$REGRESSION -r $1 -c $i 1>/tmp/regression_$i " | sleep 30 &
$REGRESSION -r $1 -c $i 1>/tmp/regression/regression_$i &
sleep 5 
done

RUN=$(squeue -u $USER | wc -l)

if [ "$RUN" -gt 1 ] ;

then
	echo "Waiting..."
	wait
	FAILED_NAME=$(grep -iH failed /tmp/regression/regression_* | awk '{ print $1 }' | sed s/://g)
	if [ -n "$FAILED_NAME" ] ;
                then
		echo "Warning a node failed the regression test, check the file $FAILED_NAME"

	else
		echo "Regression successfully passed"
        fi
else
	FAILED_NAME=$(grep -iH failed /tmp/regression/regression_* | awk '{ print $1 }' | sed s/://g)
	if [ -n "$FAILED_NAME" ] ;
 		then 
		echo "Warning a node failed the regression test, check the file $FAILED_NAME"
	else
		echo "Regression successfully passed"
	fi
fi
