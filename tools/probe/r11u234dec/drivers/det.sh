#!/bin/bash
# det.sh <sweep workdir> <binary> <out dir>: the determinism control (adapted from r11u230map/drivers/det.sh). The binary
# runs DETN (default 3) times CONCURRENTLY per row-mode for Earlgrey_0_1 and the five UVM rows (or $DETTESTS), with the
# sweep's own slang-uhdm command line (cmds.txt) and the corpus cwd; prints distinct hashes per row-mode and the sweep's
# own hash. Fail-closed on $FENCED (source drivers/env.sh); every row name is checked by word before it is opened.
source "$(dirname "$0")/env.sh" || exit 2
H=$1; BIN=$2; O=$3; N=${DETN:-3}
[ -x "$BIN" ] || { echo "det.sh: $BIN not executable" >&2; exit 2; }
[ -d "$H" ] && [ -n "$O" ] || { echo "usage: det.sh <sweep wd> <binary> <out dir>" >&2; exit 2; }
mkdir -p "$O"
for t in ${DETTESTS:-Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg}; do
 for f in $FENCED; do [ "$f" = "$t" ] && { echo "$t FENCED refused"; continue 2; }; done
 for m in default testflags; do
  d=$(ls -d $H/surelog/$m/$t-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || continue
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S* ##; s# -o \S*$##')
  cwd=$(cd $REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
  hs=""
  for i in $(seq 1 $N); do rm -f $O/${t}_${m}_$i.uhdm; (cd $cwd && eval "\"$BIN\" $args -o $O/${t}_${m}_$i.uhdm" > $O/${t}_${m}_$i.log 2>&1; echo "rc=$?" >> $O/${t}_${m}_$i.log) & done; wait
  for i in $(seq 1 $N); do hs="$hs $(md5sum < $O/${t}_${m}_$i.uhdm | cut -c1-12)/$(tail -n 1 $O/${t}_${m}_$i.log)"; rm -f $O/${t}_${m}_$i.uhdm; done
  echo "$t $m draws=$N distinct=$(echo $hs | tr ' ' '\n' | cut -d/ -f1 | sort -u | wc -l) sweep=$(md5sum < $d/slang.uhdm | cut -c1-12) |$hs"
 done
done
