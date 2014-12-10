#!/bin/bash -l

HOSTNAME=$(hostname  | sed 's/[0-9]//g')
LAST=$(ls -latr /apps/$HOSTNAME/regression/out/ | tail -n1 | awk '{ print $9 }')
LOCATION="/apps/$HOSTNAME/regression/out/$LAST/[e..i]$HOSTNAME/$HOSTNAME*"
GET_NODES=$(scontrol show res=syscheck | grep -w Nodes | awk '{ print $1 }' )
PATHTOWIDTH=5
NID=$(grep nid $LOCATION | awk '{ print $1 }' | paste -sd "," )

if [ ! -z $NID ]
	then
		echo -e  "\033[31m \e[1m This is the list of nodes that needs to be added to the syscheck reservation "
		echo -e  "since they have not passed the regression test:"
		tput sgr0;
		echo ""
		echo -e  "--> $NID <--"
		echo ""
		echo -e "\033[31m \e[1m Please run:"
		tput sgr0;
		echo ""
		echo -e "scontrol update res=syscheck $GET_NODES,$NID" 
	else
		echo -e "\033[33;32m All nodes passed the regression test"
		tput sgr0;
fi
