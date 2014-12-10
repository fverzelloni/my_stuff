#!/bin/bash -l

HOSTNAME=$(hostname  | sed 's/[0-9]//g')
LAST=$(ls -latr /apps/$HOSTNAME/regression/out/ | tail -n1 | awk '{ print $9 }')
LOCATION="/apps/$HOSTNAME/regression/out/$LAST/[e..i]$HOSTNAME/$HOSTNAME*"
NID=$(grep nid $LOCATION | awk '{ print $1 }' | paste -sd ",")
GET_NODES=$(scontrol show res=syscheck | grep -w Nodes | awk '{ print $1 }' | cut -d "[" -f2 | cut -d "]" -f1)

if [ ! -n $NID ]
	then
		echo -e  "This is the list of nodes that needs to be added to the syscheck reservation"
		echo -e  "since they have not passed the regression test:"
		echo ""
		echo -e  "\033[31m $NID"
		tput sgr0;
		echo ""
		echo "Please run:"
		echo ""
		echo -e "\033[31m scontrol update res=syscheck nodes=$GET_NODES,$NID"
		tput sgr0;
	else
		echo "All nodes passed the regression test"
fi
