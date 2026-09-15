#!/bin/bash
# flat .sv witness runner: LIST on fd 3, children </dev/null, LISTED==PROCESSED
LIST=${LIST:?}
BIN=${BIN:?}
OUT=${OUT:?}
GOLDDIR=${GOLDDIR:-$OUT}
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
mkdir -p "$OUT"
L=0; P=0
exec 3< "$LIST"
while read -r f <&3; do
  [ -n "$f" ] || continue
  L=$((L+1))
  key=$(echo "$f" | sed 's#^/tmp/wt_v11u47pris/##; s#/#_#g')
  w="$OUT/$key"; rm -rf "$w"; mkdir -p "$w"
  gw="$GOLDDIR/$key"
  if [ "$GOLDDIR" = "$OUT" ]; then
    ( cd "$(dirname "$f")" && "$SURELOG" -parse -sverilog "$(basename "$f")" -mt 0 -mp 0 -o "$w/sl" ) </dev/null >"$w/surelog.log" 2>&1
    slrc=$?
  else slrc=REUSE; fi
  GU=$(ls "$gw"/sl/slpp_all/*.uhdm 2>/dev/null | head -1)
  ( cd "$(dirname "$f")" && "$BIN" "$(basename "$f")" --single-unit -o "$w/ours.uhdm" ) </dev/null >"$w/slang.log" 2>&1
  ourc=$?
  if [ -n "$GU" ] && [ -f "$w/ours.uhdm" ]; then
    "$CMP" "$GU" "$w/ours.uhdm" >"$w/cmp.txt" 2>&1; cmprc=$?
    lines=$(wc -l < "$w/cmp.txt"); heads=$(grep -c '^LHS:' "$w/cmp.txt"; true)
    md5=$(md5sum "$w/ours.uhdm" | cut -c1-12)
  else cmprc=NA; lines=NA; heads=NA; md5=NA; fi
  echo "$key slrc=$slrc ourrc=$ourc cmprc=$cmprc heads=$heads lines=$lines db=$md5"
  P=$((P+1))
done
exec 3<&-
echo "LISTED=$L PROCESSED=$P"
[ "$L" = "$P" ] || echo "GATE-FAIL listed!=processed"
