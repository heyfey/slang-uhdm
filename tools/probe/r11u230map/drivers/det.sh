#!/bin/bash
# r11u230map (map 14's det.sh + rounds): the determinism control. A binary ($DETBIN, default $B/slang-uhdm) runs DETN
# times CONCURRENTLY per row-mode, DETROUNDS rounds one after the other (DETN x DETROUNDS draws), for Earlgrey_0_1 + the
# five UVM rows (or $DETTESTS), with the HEAD sweep's ($H) command line and cwd, output to $DETOUT. The rows are
# checked against the fence (fail closed).
. "$(dirname "$0")/env.sh"
BIN=${DETBIN:-$B/slang-uhdm}; O=${DETOUT:?export DETOUT}; N=${DETN:-3}; R=${DETROUNDS:-1}; mkdir -p $O
[ -x "$BIN" ] || { echo "det.sh: $BIN not executable" >&2; exit 2; }
for t in ${DETTESTS:-Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg}; do
 echo "$t" | grep -Pq "$FENCERE" && { echo "FENCED refused"; continue; }
 for m in default testflags; do
  d=$(ls -d $H/surelog/$m/$t-* 2>/dev/null | head -1); [ -n "$d" ] || continue
  st=$(grep "^$t,$m," $H/surelog.csv | cut -d, -f3); [ "$st" = SLANG_REJECT ] && { echo "$t $m skip $st"; continue; }
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S*slang-uhdm ##; s# -o \S*$##')
  cwd=$(cd $REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
  hs=""
  for r in $(seq 1 $R); do
   for i in $(seq 1 $N); do k=$(( (r-1)*N + i )); rm -f $O/${t}_${m}_$k.uhdm; (cd $cwd && eval "$BIN $args -o $O/${t}_${m}_$k.uhdm" > $O/${t}_${m}_$k.log 2>&1; echo "rc=$?" >> $O/${t}_${m}_$k.log) & done; wait
   for i in $(seq 1 $N); do k=$(( (r-1)*N + i )); hs="$hs $(md5sum < $O/${t}_${m}_$k.uhdm | cut -c1-12)/$(tail -1 $O/${t}_${m}_$k.log)"; done
  done
  echo "$t $m draws=$((N*R)) distinct=$(echo $hs | tr ' ' '\n' | cut -d/ -f1 | sort -u | wc -l) head=$(md5sum < $d/slang.uhdm | cut -c1-12) |$hs"
 done
done
