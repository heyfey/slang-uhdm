#!/bin/bash
# drawrow.sh <binary> <tag> <rounds> <concurrency> <reference sweep> <row> <mode>: (r11u221) repeated concurrent draws of
# one corpus row-mode with the reference sweep's recorded slang command line (its binary replaced) and the harness's
# cwd; prints the md5 histogram and keeps one database per md5 under /tmp/r11u221_drawrow_<tag>/.  Refuses a fenced row
# (fail-closed on $FENCED, drivers/env.sh).
source "$(dirname "$0")/env.sh" || exit 2
B=$1; T=$2; NR=$3; P=$4; R=$5; t=$6; m=$7
echo "$t" | grep -qP "$FENCE_RE" && { echo "fenced row refused"; exit 2; }
d=$(ls -d $R/surelog/$m/$t-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "no row"; exit 3; }
args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S* ##; s# -o \S*$##')
cwd=$(cd $R221_ROOT && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
O=/tmp/r11u221_drawrow_$T; mkdir -p $O
for r in $(seq 1 $NR); do
  for i in $(seq 1 $P); do (cd $cwd && eval "$B $args -o $O/d_${r}_$i.uhdm" > /dev/null 2>&1) & done; wait
  for i in $(seq 1 $P); do h=$(md5sum < $O/d_${r}_$i.uhdm | cut -c1-12); [ -f $O/keep_$h.uhdm ] || cp $O/d_${r}_$i.uhdm $O/keep_$h.uhdm; echo $h; rm -f $O/d_${r}_$i.uhdm; done
done | sort | uniq -c
