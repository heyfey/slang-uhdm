#!/bin/bash
# print golden path for a runner row dir
d=$1; c=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')
if [ -n "$c" ]; then echo $c/golden.uhdm; else ls $d/slpp_all/surelog.uhdm 2>/dev/null; fi
