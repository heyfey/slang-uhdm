#!/bin/bash
# usage: cmprc.sh <basename>   -> prints "cmp rc=N" for /tmp/r10earl3_rep/out_<b>
B=$1
D=/tmp/r10earl3_rep/out_$B
G=$(ls "$D"/sl/slpp_all/*.uhdm 2>/dev/null | head -1)
/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp "$G" "$D/ours.uhdm" > "$D/cmp.txt" 2>&1
echo "cmp rc=$?"
