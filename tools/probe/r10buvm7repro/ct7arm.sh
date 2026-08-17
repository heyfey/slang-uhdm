#!/usr/bin/env bash
# r10buvm7 arm runner — golden + BOTH binaries in ONE scratch dir, so the
# absolute-path lines uhdm-dump prints for Surelog's synthesized builtin.sv are
# identical across all three reads (a cross-workdir dump diff prints path noise
# as content).
#
#   PAT=<patched build> PRI=<pristine build> ct7arm.sh <arm.sv>
#
# Prints, per binary: uhdm-cmp verdict, cmp head count (grep -c '^LHS:' anchored
# at column 0), dump distance from golden, and the census TOTALS on ALL THREE
# sides.  A missing output prints NO_OUTPUT and is COUNTED — a driver that
# reached nothing must never read as perfection.
set -u
SRC=${1:?arm source}
PAT=${PAT:?set PAT to the PATCHED build}
PRI=${PRI:?set PRI to the PRISTINE build}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
CEN=${R10BUVM7CEN:-/tmp/r10buvm7cen}
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/r10buvm7_arm_$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -6 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
[ -x "$CEN" ] && "$CEN" slpp_all/surelog.uhdm "GOLD" > gold.cen && tail -1 gold.cen
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1
  if [ ! -f $tag.uhdm ]; then echo "NO_OUTPUT $B/$tag"; tail -4 $tag.log; continue; fi
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  dd=$(diff g.dump $tag.dump | grep -cE '^[<>]'; true)
  echo "$B/$tag: $res  cmpheads=$(grep -c '^LHS:' $tag.cmp; true)  dumpdiff_lines=$dd"
  [ -x "$CEN" ] && "$CEN" $tag.uhdm "$(echo $tag | tr a-z A-Z)" > $tag.cen && tail -1 $tag.cen
done
echo "WD=$D"
