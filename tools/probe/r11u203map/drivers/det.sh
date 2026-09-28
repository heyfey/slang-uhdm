#!/bin/bash
# determinism control: a binary ($DETBIN, default the HEAD binary) DETN times CONCURRENTLY per row-mode (Earlgrey_0_1 +
# the five UVM rows), the HEAD sweep's command line and cwd, output to $DETOUT (none of these rows is slang-fenced)
B=${DETBIN:-/tmp/r11u203_bin/slang-uhdm}; O=${DETOUT:-/tmp/r11u203_det/out}; N=${DETN:-3}; mkdir -p $O
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
for t in Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg; do
 for m in default testflags; do
  d=$(ls -d /tmp/intr11u196/surelog/$m/$t-* 2>/dev/null | head -1); [ -n "$d" ] || continue
  st=$(grep "^$t,$m," /tmp/intr11u196/surelog.csv | cut -d, -f3); [ "$st" = SLANG_REJECT ] && { echo "$t $m skip $st"; continue; }
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S*slang-uhdm ##; s# -o \S*$##')
  cwd=$(cd /tmp/wt_r11u203 && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
  for i in $(seq 1 $N); do rm -f $O/${t}_${m}_$i.uhdm; (cd $cwd && eval "$B $args -o $O/${t}_${m}_$i.uhdm" > $O/${t}_${m}_$i.log 2>&1; echo "rc=$?" >> $O/${t}_${m}_$i.log) & done; wait
  echo "$t $m $(for i in $(seq 1 $N); do echo -n "$(md5sum < $O/${t}_${m}_$i.uhdm | cut -c1-12)/$(tail -1 $O/${t}_${m}_$i.log) "; done) head=$(md5sum < $d/slang.uhdm | cut -c1-12)"
 done
done
