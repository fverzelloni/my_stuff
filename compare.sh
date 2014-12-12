#!/bin/bash

DIFF=$(diff -a --suppress-common-lines -y $1 $2 )

if [ -n "$DIFF" ]
	then
		echo $DIFF | sed 's/,/ /g' | mail -s "Nodes down update"  fverzell@cscs.ch 
fi
