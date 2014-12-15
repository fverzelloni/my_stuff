#!/bin/bash

COMMAND=`/apps/daint/system/scripts/generate_down_node_list.sh -C`

if [ ! -z "$COMMAND" ]
	then
		echo "$COMMAND" | sed 's/,/ /g' | mail -s "Nodes down update"  fverzell@cscs.ch 
fi
