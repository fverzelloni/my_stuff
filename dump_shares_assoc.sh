#!/bin/bash -l

####################################
#
# Dump shares association
#
####################################

#VAR

#CLUSTER=$(hostname  | sed 's/[0-9]//g')
CLUSTER=$(hostname  | sed 's/smw//g')
HOSTNAME=$(ssh $CLUSTER hostname)
SACCTMGR=/opt/slurm/default/bin/sacctmgr
SACCTMGREXT=/apps/$CLUSTER/slurm/default/bin/sacctmgr

#RUN

if [[ $HOSTNAME =~ $CLUSTER[[:digit:]]{3} ]] ; then

  ssh crayadm@$CLUSTER $SACCTMGREXT dump cluster=$CLUSTER >& "$CLUSTER"_assoc_`date +"%m_%d_%Y_\%H\%M\%S"`.txt

else

  ssh crayadm@$CLUSTER $SACCTMGR dump cluster=$CLUSTER >& "$CLUSTER"_assoc_`date +"%m_%d_%Y_\%H\%M\%S"`.txt

fi
