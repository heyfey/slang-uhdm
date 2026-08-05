#!/bin/bash
# usage: cmprc4.sh <basename>   -> prints "cmp rc=N"
B=$1
D=/tmp/r10earl6_rep/out_$B
G=$(ls "$D"/sl/slpp_all/*.uhdm 2>/dev/null | head -1)
/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp "$G" "$D/ours.uhdm" > "$D/cmp.txt" 2>&1
echo "cmp rc=$?"
