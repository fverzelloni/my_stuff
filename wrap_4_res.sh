#!/bin/bash


# ./wrapres.sh add node=nid00059 res=syscheck

GET_NODES=$(scontrol show res=$2 | grep -w Nodes | awk '{ print $1 }' | cut -d "[" -f2 | cut -d "]" -f1)
DATE=$(date +%d-%m-%Y)
MACHINE=$(hostname | sed 's/[0-9]//g')
REASON=$4
NOTIFIED=$5

case "$1" in
        addnode)
			scontrol update res=$2 $GET_NODES,$3
			echo "$3,$DATE,$REASON,$NOTIFIED" >> /apps/$MACHINE/system/nodes_in_reservation.txt
                        ;;
        create)
			scontrol create res=$2 nodes=$3 account=csstaff flag=maint,overlap starttime=now duration=infinite
			echo "$3,$DATE,$REASON,$NOTIFIED" >> /apps/$MACHINE/system/nodes_in_reservation.txt
                        ;;
        *)
                        echo "usage: ${0##*/} {add} node reason notifiedby"
                        exit 1
                        ;;
esac
