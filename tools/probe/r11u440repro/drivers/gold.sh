#!/bin/bash
# gold.sh <workdir of a row>: print the golden uhdm path
d=$(grep -o 'golden cache hit [^)]*' $1/cmds.txt | cut -d' ' -f4)
if [ -n "$d" ]; then echo $d/golden.uhdm; else ls $1/slpp_all/surelog.uhdm; fi
