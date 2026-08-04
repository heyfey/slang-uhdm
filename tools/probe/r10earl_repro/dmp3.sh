#!/bin/bash
# usage: dmp2.sh <basename>   -> dumps both sides into out_<b>/{g,o}.dump
B=$1
D=/tmp/r10earl3_rep/out_$B
G=$(ls "$D"/sl/slpp_all/*.uhdm 2>/dev/null | head -1)
/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump "$G" > "$D/g.dump" 2>&1
/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump "$D/ours.uhdm" > "$D/o.dump" 2>&1
echo "wrote $D/g.dump $D/o.dump"
wc -l "$D/g.dump" "$D/o.dump"
