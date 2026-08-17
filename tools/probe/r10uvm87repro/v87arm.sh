#!/usr/bin/env bash
# v87 verifier arm runner. LHS is ALWAYS golden (Surelog).
set -u
SRC=${1:?}
PAT=${PAT:-/tmp/v87_bin/slang-uhdm.pat}
PRI=${PRI:-/tmp/v87_bin/slang-uhdm.pris}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
B=$(basename "$SRC" .sv)
D=/tmp/v87_arm_$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/"; LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -12 surelog.log; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1
  if [ ! -f $tag.uhdm ]; then echo "NO_OUTPUT $B/$tag"; tail -4 $tag.log; continue; fi
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  gd=$(diff g.dump $tag.dump | grep -cE '^[<>]'; true)
  echo "$B/$tag: $res cmpheads=$(grep -c '^LHS:' $tag.cmp; true) golden_vs_${tag}_difflines=$gd"
done
if [ -f pris.dump ] && [ -f pat.dump ]; then
  if cmp -s pris.dump pat.dump; then echo "$B: pris/pat BYTE-IDENTICAL"
  else echo "$B: pris->pat moved $(diff pris.dump pat.dump | grep -cE '^[<>]'; true) dump lines"; fi
fi
echo "WD=$D"
