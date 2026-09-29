#!/bin/bash
# r11u222map (map 13's det.sh, paths from the checkout and env.sh): the determinism control. A binary ($DETBIN,
# default $B/slang-uhdm) runs DETN times CONCURRENTLY per row-mode (Earlgrey_0_1 + the five UVM rows, or $DETTESTS)
# with the HEAD sweep's ($H) command line and cwd, output to $DETOUT. None of these rows is slang-fenced (checked).
. "$(dirname "$0")/env.sh"
BIN=${DETBIN:-$B/slang-uhdm}; O=${DETOUT:?export DETOUT}; N=${DETN:-3}; mkdir -p $O
for t in ${DETTESTS:-Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg}; do
 echo "$t" | grep -Pq "$FENCERE" && { echo "FENCED refused"; continue; }
 for m in default testflags; do
  d=$(ls -d $H/surelog/$m/$t-* 2>/dev/null | head -1); [ -n "$d" ] || continue
  st=$(grep "^$t,$m," $H/surelog.csv | cut -d, -f3); [ "$st" = SLANG_REJECT ] && { echo "$t $m skip $st"; continue; }
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S*slang-uhdm ##; s# -o \S*$##')
  cwd=$(cd $REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
  for i in $(seq 1 $N); do rm -f $O/${t}_${m}_$i.uhdm; (cd $cwd && eval "$BIN $args -o $O/${t}_${m}_$i.uhdm" > $O/${t}_${m}_$i.log 2>&1; echo "rc=$?" >> $O/${t}_${m}_$i.log) & done; wait
  echo "$t $m $(for i in $(seq 1 $N); do echo -n "$(md5sum < $O/${t}_${m}_$i.uhdm | cut -c1-12)/$(tail -1 $O/${t}_${m}_$i.log) "; done) head=$(md5sum < $d/slang.uhdm | cut -c1-12)"
 done
done
