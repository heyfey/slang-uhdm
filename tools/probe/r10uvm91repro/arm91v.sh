#!/usr/bin/env bash
# v91 VERIFIER arm runner. golden(Surelog) + both binaries in ONE scratch dir.
# LHS is ALWAYS golden. Prints per-binary cmp heads and dump-diff-vs-GOLDEN.
set -u
SRC=${1:?arm source}
PAT=${PAT:-/tmp/v91_bin/slang-uhdm.pat}
PRI=${PRI:-/tmp/v91_bin/slang-uhdm.pris}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/.local/bin/uhdm-dump
CMP=$HOME/.local/bin/uhdm-cmp
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/v91_arm_$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -8 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1
  if [ ! -f $tag.uhdm ]; then echo "NO_OUTPUT $B/$tag rc"; tail -4 $tag.log; continue; fi
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  dd=$(diff g.dump $tag.dump | grep -cE '^[<>]'; true)
  echo "$B/$tag: $res  cmpheads=$(grep -c '^LHS:' $tag.cmp; true)  cmplines=$(wc -l < $tag.cmp)  DUMPDIFF_VS_GOLDEN=$dd"
done
if [ -f pris.dump ] && [ -f pat.dump ]; then
  cmp -s pris.dump pat.dump && echo "$B: pris/pat BYTE-IDENTICAL" \
    || echo "$B: pris->pat MOVED $(diff pris.dump pat.dump | grep -cE '^[<>]'; true) dump lines"
fi
echo "WD=$D"
