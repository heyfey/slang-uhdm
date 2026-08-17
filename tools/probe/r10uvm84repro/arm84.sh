#!/usr/bin/env bash
# r10uvm84 arm runner — MEASUREMENT-ONLY.  golden(Surelog) + BOTH binaries in ONE
# scratch dir so uhdm-dump's absolute paths are identical across the three reads.
#
#   PAT=<patched build> PRI=<pristine build> arm84.sh <arm.sv>
#
# LHS is ALWAYS golden.  Heads counted with grep -c '^LHS:' anchored at column 0
# (uhdm-cmp prints `decompile:` twice per side for ONE head).  A missing output
# prints NO_OUTPUT and is COUNTED.
set -u
SRC=${1:?arm source}
PAT=${PAT:-}
PRI=${PRI:-}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/r10uvm84_arm_$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -8 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  [ -n "$bin" ] || continue
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1
  if [ ! -f $tag.uhdm ]; then echo "NO_OUTPUT $B/$tag"; tail -4 $tag.log; continue; fi
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  dd=$(diff g.dump $tag.dump | grep -cE '^[<>]'; true)
  echo "$B/$tag: $res  cmpheads=$(grep -c '^LHS:' $tag.cmp; true)  dumpdiff_lines=$dd"
done
if [ -f pris.dump ] && [ -f pat.dump ]; then
  cmp -s pris.dump pat.dump && echo "$B: pris/pat dumps BYTE-IDENTICAL" \
    || echo "$B: pris->pat moved $(diff pris.dump pat.dump | grep -cE '^[<>]'; true) dump lines"
fi
echo "WD=$D"
