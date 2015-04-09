#!/bin/bash -l

# Data collection
PDSH=/opt/cray/pdsh/default/bin/pdsh
XTPROCADMIN=/opt/cray/sdb/default/bin/xtprocadmin
UPNODES_LIST=$( $XTPROCADMIN | grep compute | grep up | awk '{ print $3 }' | tr "\n" "," )
UPNODES_NUMB=$( $XTPROCADMIN | grep compute | grep -c up)
NODESOUT=$($PDSH -u 2 -w $UPNODES_LIST date 2>&1 )
OK_NODES=$(echo "$NODESOUT" |  wc -l )
TIMEOUT=$(echo "$NODESOUT" | grep "command timeout" | wc -l )
SSHERRNODE=$(echo "$NODESOUT" | grep "Connection refused" | awk '{ print $1 }' | tr ":" " ")
SSHERR=$(echo "$NODESOUT" | grep "Connection refused" | wc -l )

if [ ! -z "$SSHERRNODE" ]
	then
		echo $SSHERRNODE $(date +%d%m%y) >> /var/log/ssh_fail.log 
		for i in $SSHERRNODE
                  do
                  ssh root@login1 "/opt/cray/nodehealth/default/bin/pcmd -t 5 -r -n $i '/etc/init.d/sshd start'"
                   done
	else
		echo "No nodes to fix :-)"
fi
