#!/bin/bash

FILE=/tmp/osc
RPCS=64
DIRTY=256
# Get the OST path
#  pdsh -w nid000[32-43] ls /proc/fs/lustre/osc/ | grep snx | sed 's/://g'
#  pdsh -w nid000[32-43] ls /proc/fs/lustre/osc/ | grep sant | sed 's/://g'

cat /tmp/osc | while  read -r f1 f2 ; do echo " ssh $f1 \"echo $DIRTY > /proc/fs/lustre/osc/$f2/max_dirty_mb\" "; done 
cat /tmp/osc | while  read -r f1 f2 ; do echo " ssh $f1 \"echo $RPCS  > /proc/fs/lustre/osc/$f2/max_rpcs_in_flight\" "; done
