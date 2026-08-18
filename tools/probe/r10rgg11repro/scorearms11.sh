#!/usr/bin/env bash
# r10rgg11/scorearms11.sh — for a NAMED LIST of single-file arms, build the
# GOLDEN with Surelog and both of our databases, and classify every ELAB port
# actual row  OK / FIXED / BROKEN / STILL.  An arm that MOVES is not enough:
# it has to move TOWARD golden, and this is what says so.
#   usage: scorearms11.sh <base-bin> <pat-bin> <outfile> <top.sv> [<top.sv> ...]
set -u
A=${1:?base}; B=${2:?pat}; OUT=${3:?out}; shift 3
CEN=/tmp/r10rgg11_pcensus
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
ok=0; fixed=0; broken=0; still=0; nodb=0; n=0
{
for f in "$@"; do
  n=$((n+1))
  d=$(dirname "$f"); b=$(basename "$f")
  w=$(mktemp -d /tmp/r10rgg11_arm.XXXXXX)
  ( cd "$d" && "$SURELOG" -parse "$b" -mt 0 -mp 0 -o "$w/sl" >/dev/null 2>&1 </dev/null )
  ( cd "$d" && "$A" "$b" --single-unit -o "$w/a.uhdm" >/dev/null 2>&1 </dev/null )
  ( cd "$d" && "$B" "$b" --single-unit -o "$w/b.uhdm" >/dev/null 2>&1 </dev/null )
  g=$w/sl/slpp_all/surelog.uhdm
  if [ ! -f "$g" ] || [ ! -f "$w/a.uhdm" ] || [ ! -f "$w/b.uhdm" ]; then
    echo "NODB $f"; nodb=$((nodb+1)); rm -rf "$w"; continue
  fi
  "$CEN" "$g"       2>/dev/null | grep '^ELAB|PORT|' | LC_ALL=C sort > "$w/g.t"
  "$CEN" "$w/a.uhdm" 2>/dev/null | grep '^ELAB|PORT|' | LC_ALL=C sort > "$w/a.t"
  "$CEN" "$w/b.uhdm" 2>/dev/null | grep '^ELAB|PORT|' | LC_ALL=C sort > "$w/b.t"
  while IFS=$'\t' read -r k gv; do
    av=$(awk -F'\t' -v k="$k" '$1==k{print $2}' "$w/a.t")
    bv=$(awk -F'\t' -v k="$k" '$1==k{print $2}' "$w/b.t")
    if   [ "$av" = "$gv" ] && [ "$bv" = "$gv" ]; then ok=$((ok+1))
    elif [ "$av" != "$gv" ] && [ "$bv" = "$gv" ]; then fixed=$((fixed+1)); echo "FIXED  $f $k  GOLD=$gv BASE=$av PAT=$bv"
    elif [ "$av" = "$gv" ] && [ "$bv" != "$gv" ]; then broken=$((broken+1)); echo "BROKEN $f $k  GOLD=$gv BASE=$av PAT=$bv"
    else still=$((still+1)); fi
  done < "$w/g.t"
  rm -rf "$w"
done
echo "-- arms=$n OK=$ok FIXED=$fixed BROKEN=$broken STILL=$still NODB=$nodb"
} > "$OUT" 2>&1
tail -1 "$OUT"
