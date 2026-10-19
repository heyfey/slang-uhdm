#!/bin/bash
# dd.sh <relpath.sv> [tag] : normalized dump diff golden vs ours (control, or sv/<tag>)
r=${1%.sv}; d=/tmp/intr11u408/svtests/work/$r; o=$d; [ -n "$2" ] && o=/tmp/r11u410_scratch/sv/$2/$r
g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[^) ]*' $d/cmds.txt | head -1)/golden.uhdm
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
norm(){ sed -E 's/, id:[0-9]+//; s#file:[^,]*/##; s#/[^ ,]*/##g'; }
w=/tmp/r11u410_scratch/sv/dd; mkdir -p $w
$D $g 2>/dev/null | norm > $w/g.txt; $D $o/slang.uhdm 2>/dev/null | norm > $w/s.txt
diff $w/g.txt $w/s.txt
