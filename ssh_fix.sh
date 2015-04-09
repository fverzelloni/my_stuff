#!/bin/bash -l

# Data collection
PDSH=/opt/cray/pdsh/2.26-1.0502.51215.1.1.ari/bin/pdsh
XTPROCADMIN=/opt/cray/sdb/1.0-1.0502.55976.5.27.ari/bin/xtprocadmin
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
		#for i in echo $SSHERRNODE ; do  ssh root@dora01 "hostname && /opt/cray/nodehealth/5.1-1.0502.56494.9.2.ari/bin/pcmd -t 5 -r -n $i '/etc/init.d/sshd start'" ; done
		for i in echo $SSHERRNODE ; do  ssh root@dora01 "hostname && /opt/cray/nodehealth/5.1-1.0502.56494.9.2.ari/bin/pcmd -t 5 -r -n $i '/etc/init.d/sshd.logging start'" ; done
	else
		echo "No nodes to fix :-)"
fi
