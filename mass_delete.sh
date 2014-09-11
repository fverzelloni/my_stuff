#!/bin/bash
#test=echo
width=100

lfs find $* -t f | xargs -n $width $test rm -f
