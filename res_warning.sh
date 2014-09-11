#!/bin/bash

#
# ********************************************************************
# * 001 * 10-09-14 * Fabio Verzelloni / CSCS  * File created         *
# * 002 *          *                          *                      *
# * 003 *          *                          *                      *
# ********************************************************************
#
#---------------------------------------------------------------------
# CONFIGURATION
#---------------------------------------------------------------------
TODAY=$(date +%Y-%m-%d)
WARN_DATE1=$(date -d "+1 days" "+%Y-%m-%d")
WARN_DATE2=$(date -d "+2 days" "+%Y-%m-%d")
MAINTDAY2=$(cat maintenance.txt | grep $WARN_DATE2)
MAINTDAY1=$(cat /apps/ela/system/etc/maintenance.txt | grep $WARN_DATE1)
HOSTNAME=$(hostname | sed 's/[0-9]//g')
SCONTROL="/apps/$HOSTNAME/slurm/default/bin/scontrol"
RES_CHECK=$($SCONTROL show res=maint)
RECIPIENT=

#---------------------------------------------------------------------
# SCRIPT
#---------------------------------------------------------------------

if [ "$WARN_DATE2" == "$MAINTDAY2" ]
	then
		if [ "$RES_CHECK" == "Reservation maint not found" ]
			then
				echo -e "No 'maint' reservation on $HOSTNAME, If your system will be under maintenance the next $MAINTDAY2, remember to create the 'maint' reservation: \n \nscontrol create res=maint starttime="$MAINTDAY2"T08:00:00 duration=10:00:00 nodes=all accounts=csstaff,cray,usup flag=maint,overlap" | mail -s "Reservation 'maint' not present on $HOSTNAME" fverzell@cscs.ch
		fi
	else
		if [ "$WARN_DATE1" == "$MAINTDAY1" ]
			then
                		if [ "$RES_CHECK" == "Reservation maint not found" ]
                        		then
                                		echo -e "No 'maint' reservation on $HOSTNAME, If your system will be under maintenance the next $MAINTDAY1, remember to create the 'maint' reservation: \n \n scontrol create res=maint starttime="$MAINTDAY1"T08:00:00 duration=10:00:00 nodes=all accounts=csstaff,cray,usup flag=maint,overlap" | mail -s "Reservation 'maint' not present on $HOSTNAME" fverzell@cscs.ch
                		fi

		fi
fi
