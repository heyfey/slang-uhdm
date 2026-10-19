#!/bin/bash
# dd.sh <rel-without-.sv> <workroot>: normalized dump distance golden vs ours
r=$1; d=$2/svtests/work/$r
g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[^) ]*' $d/cmds.txt | head -1)/golden.uhdm
[ -f $g ] || g=$(ls $d/slpp_all/surelog.uhdm 2>/dev/null)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
norm(){ sed -E 's/, id:[0-9]+//; s#file:[^,]*/##; s#/[^ ,]*/##g'; }
w=/tmp/v11u410_s/dd_$$; mkdir -p $w
$D $g 2>/dev/null | norm > $w/g.txt; $D $d/slang.uhdm 2>/dev/null | norm > $w/s.txt
diff $w/g.txt $w/s.txt | grep -c '^[<>]'; rm -rf $w
