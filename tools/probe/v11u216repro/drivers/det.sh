#!/bin/bash
# v11u216: copied from r11u216repro/drivers/det.sh.
# r11u212 (from r11u209) (copied from r11u205dec/drivers/det.sh; the reference sweep is $DETREF, default this pass's sweep of the same
# binary). Determinism control: a binary ($DETBIN) DETN times CONCURRENTLY per row-mode (Earlgrey_0_1 + the five UVM
# rows), the reference sweep's command line and cwd, output to $DETOUT (none of these rows is slang-fenced; the loop
# refuses a fenced name all the same).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
B=${DETBIN:?DETBIN}; O=${DETOUT:?DETOUT}; N=${DETN:-3}; REF=${DETREF:?DETREF}; mkdir -p $O
for t in Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg; do
 echo "$t" | grep -Pqw "$FENCE_RE" && { echo "fenced refused"; continue; }
 for m in default testflags; do
  d=$(ls -d $REF/surelog/$m/$t-* 2>/dev/null | head -1); [ -n "$d" ] || continue
  st=$(grep "^$t,$m," $REF/surelog.csv | cut -d, -f3); [ "$st" = SLANG_REJECT ] && { echo "$t $m skip $st"; continue; }
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S* ##; s# -o \S*$##')
  cwd=$(cd $REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
  for i in $(seq 1 $N); do rm -f $O/${t}_${m}_$i.uhdm; (cd $cwd && eval "$B $args -o $O/${t}_${m}_$i.uhdm" > $O/${t}_${m}_$i.log 2>&1; echo "rc=$?" >> $O/${t}_${m}_$i.log) & done; wait
  echo "$t $m $(for i in $(seq 1 $N); do echo -n "$(md5sum < $O/${t}_${m}_$i.uhdm | cut -c1-12)/$(tail -1 $O/${t}_${m}_$i.log) "; done) sweep=$(md5sum < $d/slang.uhdm | cut -c1-12)"
 done
done
