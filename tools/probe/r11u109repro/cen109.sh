#!/bin/bash
# cen109.sh <rowdir> <outroot>: dump one sweep row's golden + ours once and run the
# a-priori signature census (sig109.py).  Row dirs: <sweep workdir>/{sl,u2r}/<mode>/<row>.
d=$1; out=$2
rel=$(echo "$d" | awk -F/ '{print $(NF-2)"/"$(NF-1)"/"$NF}'); key=$(echo "$rel" | tr '/' '_')
o=$out/$key; mkdir -p $o
g=$(grep -o 'cache hit [^)]*' $d/cmds.txt 2>/dev/null | awk '{print $3}')/golden.uhdm
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
[ -f "$g" ] && [ ! -s $o/g.dump ] && timeout 600 $D $g > $o/g.dump 2>/dev/null
[ -f $d/slang.uhdm ] && timeout 600 $D $d/slang.uhdm > $o/o.dump 2>/dev/null
[ -s $o/g.dump ] && [ -s $o/o.dump ] && python3 "$(dirname "$(readlink -f "$0")")/sig109.py" $o/g.dump $o/o.dump > $o/sig.txt 2>&1
echo "$rel $(cat $o/sig.txt 2>/dev/null | tr '\n' ' ')"
