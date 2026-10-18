#!/bin/bash
# usage: r11u402_pair.sh <rowdir>  -> prints golden path
d=$1; c=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | head -1 | awk '{print $4}')
if [ -n "$c" ]; then echo $c/golden.uhdm; else ls $d/slpp_all/surelog.uhdm 2>/dev/null || ls $d/slpp_unit/surelog.uhdm; fi
