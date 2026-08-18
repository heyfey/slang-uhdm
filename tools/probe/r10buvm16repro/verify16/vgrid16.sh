#!/usr/bin/env bash
# r10vbuvm16 (VERIFIER) — three-way cell table, golden / pristine / patched,
# for every `new` call's arguments.  Independent re-implementation of the
# implementer's grid16.sh with NO hard-coded pass paths.
#   usage: PRISTINE=<bin> PATCHED=<bin> CEN=<census> vgrid16.sh <file.sv>
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"; CEN=${CEN:-/tmp/vbuvm16_cen}
SRC=${1:?file.sv}
SL=$HOME/git-repos/Surelog/build/bin/surelog
[ -x "$CEN" ] || { echo "FATAL no census $CEN"; exit 3; }
[ -x "$PRISTINE" ] || { echo "FATAL no PRISTINE"; exit 3; }
[ -x "$PATCHED" ]  || { echo "FATAL no PATCHED"; exit 3; }
[ -x "$SL" ] || { echo "FATAL no surelog"; exit 3; }
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/vbuvm16_grid_XXXXXX)
cp "$SRC" "$W/$B.sv"
cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -nocache -d coveruhdm > sl.log 2>&1
G=slpp_all/surelog.uhdm
[ -s "$G" ] || { echo "SURELOG_FAIL $B (wd=$W)"; tail -8 sl.log; exit 4; }
"$PRISTINE" "$B.sv" -o p.uhdm > p.log 2>&1; prc=$?
"$PATCHED"  "$B.sv" -o q.uhdm > q.log 2>&1; qrc=$?
echo "   rc: pristine=$prc patched=$qrc"
[ -s p.uhdm ] || { echo "SLANG_REJECT(pristine) $B (wd=$W)"; tail -8 p.log; exit 5; }
[ -s q.uhdm ] || { echo "SLANG_REJECT(patched) $B (wd=$W)"; tail -8 q.log; exit 5; }
raw() {
  "$CEN" "$1" "$2" > "$2.txt" 2>&1
  grep -q "^RESTORE_FAIL" "$2.txt" && { echo "FATAL restore $1" >&2; exit 6; }
  awk -v t="$2" '$1=="NEW" && $2==t {
      key=substr($3,5); $1=""; $2=""; $3=""; sub(/^ +/,""); sub(/ sub=.*$/,"");
      print key "\t" $0 }' "$2.txt"
}
raw "$G" G > graw.txt; raw p.uhdm P > praw.txt; raw q.uhdm Q > qraw.txt
grp() { LC_ALL=C sort "$1" |
  awk -F'\t' '{ if ($1==k) { c=c " ,, " $2 } else { if (k!="") print k "\t" c; k=$1; c=$2 } }
              END { if (k!="") print k "\t" c }'; }
ng=$(wc -l < graw.txt)
echo "== vgrid $B  wd=$W  goldenNEWS=$ng pristine=$(wc -l < praw.txt) patched=$(wc -l < qraw.txt)"
[ "$ng" -gt 0 ] || { echo "FATAL arm $B has ZERO golden new-calls"; exit 7; }
grp graw.txt > gk.txt; grp praw.txt > pk.txt; grp qraw.txt > qk.txt
LC_ALL=C join -t$'\t' -a1 -a2 -e - -o 0,1.2,2.2 -j1 gk.txt pk.txt > gp.txt
LC_ALL=C join -t$'\t' -a1 -a2 -e - -o 0,1.2,1.3,2.2 -j1 gp.txt qk.txt |
awk -F'\t' '{
  v = ($2==$3 && $3==$4) ? "same" :
      ($2!=$3 && $2==$4) ? "CONVERTED" :
      ($2==$3 && $2!=$4) ? "OVER-FIRE" :
      ($2!=$3 && $2!=$4 && $3!=$4) ? "MOVED-STILL-WRONG" : "residue";
  c[v]++;
  if (v!="same" || ENVIRON["VERBOSE"]=="1")
    printf "%-18s %s\n   G=%s\n   P=%s\n   Q=%s\n", v, $1, $2, $3, $4 }
  END { printf "-- "; for (k in c) printf "%s=%d ", k, c[k]; printf "\n" }'
