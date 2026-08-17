#!/usr/bin/env bash
# vbuvm7 verifier arm runner (own namespace).  PAT/PRI env, one .sv per call.
set -u
SRC=${1:?arm source}
PAT=${PAT:?}
PRI=${PRI:?}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
CEN=/tmp/vbuvm7_cen
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/vbuvm7_arm_$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
if [ ! -f slpp_all/surelog.uhdm ]; then echo "SURELOG_FAIL $B"; grep -iE '\[(FTL|SNT|SYNT|ERR)' surelog.log | head -6; exit 5; fi
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
"$CEN" slpp_all/surelog.uhdm GOLD > gold.cen 2>/dev/null; tail -1 gold.cen
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1
  if [ ! -f $tag.uhdm ]; then echo "NO_OUTPUT $B/$tag"; grep -iE 'error' $tag.log | head -4; continue; fi
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  dd=$(diff g.dump $tag.dump | grep -cE '^[<>]'; true)
  echo "$B/$tag: $res  cmpheads=$(grep -c '^LHS:' $tag.cmp; true)  dumpdiff=$dd"
  "$CEN" $tag.uhdm "$(echo $tag | tr a-z A-Z)" > $tag.cen 2>/dev/null; tail -1 $tag.cen
done
echo "WD=$D"
