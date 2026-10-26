#!/bin/bash
# dd.sh <key> <tag>: diff golden dump vs ours dump (normalized, unsorted)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || exit 2
o=/tmp/v11u433_scr/out/$1/$2; gd=$(cat $o/gold)
$D $gd/slpp_all/surelog.uhdm 2>/dev/null | sed 's/^ *//; s/, id:[0-9]*//; s/(id:[0-9]*)//' | sed 's|[^ ]*/||g' > $o/g.txt
$D $o/ours.uhdm 2>/dev/null | sed 's/^ *//; s/, id:[0-9]*//; s/(id:[0-9]*)//' | sed 's|[^ ]*/||g' > $o/o.txt
diff $o/g.txt $o/o.txt
