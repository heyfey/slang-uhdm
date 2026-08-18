#!/usr/bin/env bash
# r10uvm92 VERIFIER arm runner. golden + both binaries in ONE scratch dir.
set -u
SRC=${1:?arm source}
PAT=${PAT:-/tmp/v92_bin/slang-uhdm.pat}
PRI=${PRI:-/tmp/v92_bin/slang-uhdm.pris}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/v92_arm_$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -n20 surelog.log; exit 5; }
echo "$B: surelog ERR=$(grep -c '^\[ERR' surelog.log; true) FTL=$(grep -c '^\[FTL' surelog.log; true)"
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1
  rc=$?
  if [ ! -f $tag.uhdm ]; then echo "NO_OUTPUT $B/$tag rc=$rc"; tail -n6 $tag.log; continue; fi
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  "$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1; crc=$?
  echo "$B/$tag: rc=$rc cmp_rc=$crc cmplines=$(wc -l < $tag.cmp) heads=$(grep -c '^LHS:' $tag.cmp; true)"
done
if [ -f pris.dump ] && [ -f pat.dump ]; then
  cmp -s pris.dump pat.dump && echo "$B: pris/pat dumps BYTE-IDENTICAL" \
    || echo "$B: pris->pat moved $(diff pris.dump pat.dump | grep -cE '^[<>]'; true) dump lines"
fi
echo "WD=$D"
