#!/bin/bash
# dump.sh <case dir> <tag>: path-normalized uhdm-dump of golden (tag gold) or of ours (out/<key>/<tag>)
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || { echo "no uhdm-dump"; exit 2; }
c=$(cd $1 && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
if [ "$2" = gold ]; then f=$($(dirname $0)/goldpath.sh $c); else f=/tmp/r11u459_scr/out/$key/$2/ours.uhdm; fi
$D $f 2>/dev/null | sed 's/, id:[0-9]*//; s|/tmp/r11u459_scr/gold/[0-9a-f]*/||; s|'"$c"'/||'
