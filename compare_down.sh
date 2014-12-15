#!/bin/bash -l


# VAR's
HOSTNAME="$(hostname | sed 's/[0-9]//g')"
COMMAND=`/apps/$HOSTNAME/system/scripts/generate_down_node_list.sh -C`
RECIPIENT=email@email.ch

if [ ! -z "$COMMAND" ]
	then
		echo "$COMMAND" | sed 's/,/ /g' | mail -s "Nodes down update"  $RECIPIENT
fi
