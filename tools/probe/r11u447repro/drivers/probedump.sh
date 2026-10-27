#!/bin/bash
# usage: probedump.sh <new probe dir> <control probe dir> <out>: path-normalized uhdm-dump compare of every database
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump; [ -x "$D" ] || exit 2
A=$1; B=$2; export A B D
one() { f=$1; a=$($D $A/$f 2>/dev/null | sed "1d; s#/tmp/wt_r11u447/##g; s#/home/heyfey/git-repos/slang-uhdm/##g" | md5sum | cut -c1-8); b=$($D $B/$f 2>/dev/null | sed "1d; s#/tmp/wt_r11u447/##g; s#/home/heyfey/git-repos/slang-uhdm/##g" | md5sum | cut -c1-8); [ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"; }
export -f one
(cd $A && ls *.uhdm) | xargs -P 3 -I{} bash -c 'one {}' > $3
grep -c SAME $3; grep DIFF $3 | head
