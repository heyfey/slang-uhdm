#!/usr/bin/env bash
# three-way: golden vs pristine vs patched vs FIXED
set -u
SRC=${1:?}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/.local/bin/uhdm-dump
CMP=$HOME/.local/bin/uhdm-cmp
B=$(basename "$SRC" .sv); D=/tmp/v87_arm_$B
rm -rf "$D"; mkdir -p "$D"; cp "$SRC" "$D/"; LEAF=$(basename "$SRC"); cd "$D"
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; exit 5; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
for tag in pris pat fix; do
  bin=/tmp/v87_bin/slang-uhdm.$tag
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1
  [ -f $tag.uhdm ] || { echo "NO_OUTPUT $B/$tag"; tail -4 $tag.log; continue; }
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  echo "$B/$tag: $res heads=$(grep -c '^LHS:' $tag.cmp; true) g_vs_${tag}=$(diff g.dump $tag.dump | grep -cE '^[<>]'; true)"
done
cmp -s pat.dump fix.dump && echo "$B: pat/fix BYTE-IDENTICAL" || echo "$B: pat->fix moved $(diff pat.dump fix.dump | grep -cE '^[<>]'; true) lines"
