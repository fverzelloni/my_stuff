#!/bin/bash -l

HOSTNAME=$(hostname  | sed 's/[0-9]//g')
LAST=$(ls -latr /apps/$HOSTNAME/regression/out/ | tail -n1 | awk '{ print $9 }')
LOCATION="/apps/$HOSTNAME/regression/out/$LAST/[e..i]$HOSTNAME/$HOSTNAME*"
NID=$(grep nid $LOCATION | awk '{ print $1 }' | paste -sd ",")

echo $NID
