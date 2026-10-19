#!/bin/bash
# dd.sh <row> <wd>: dump distance golden vs wd's slang.uhdm
r=$1; W=$2; D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[^) ]*' /tmp/intr11u410/svtests/work/$r/cmds.txt | head -1)/golden.uhdm
norm(){ sed -E 's/, id:[0-9]+//; s#/tmp/[a-z0-9_]+/svtests/work/[^ ,]*##g; s#^/[^ ]*: Restored#Restored#'; }
w=/tmp/v11u412_dd/$(echo $r | tr / _); mkdir -p $w
[ -f $w/g.txt ] || $D $g 2>/dev/null | norm > $w/g.txt
$D $W/svtests/work/$r/slang.uhdm 2>/dev/null | norm > $w/$(basename $W).txt
echo "$r $(basename $W) $(diff $w/g.txt $w/$(basename $W).txt | grep -c '^[<>]')"
