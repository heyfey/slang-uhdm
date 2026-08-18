#!/usr/bin/env bash
# r10buvm16repro/grid16.sh — THE THREE-WAY CELL TABLE for one arm, keyed on the
# question this pass owns: what vpiActual does each ARGUMENT of a `new` call
# carry?
#
#   usage: PRISTINE=<bin> PATCHED=<bin> grid16.sh <file.sv>
#
# Cell value: the census row's `nm= par= sub= sk= si= na= nref= a=` — the call's
#             own PARENT KIND plus every argument ref's Actual_group, in order.
#             IDs and ADDRESSES appear nowhere.
# Verdicts:   same / CONVERTED (P wrong, Q == G) / OVER-FIRE (P right, Q wrong)
#             / MOVED-STILL-WRONG / residue (G != P == Q, untouched)
#
# GUARDS (each an ops trap this campaign has paid for, carried from grid14.sh):
#   * Surelog AND BOTH binaries run in the SAME directory — a UHDM database
#     records the source file's ABSOLUTE path, so two CWDs make every object
#     differ (buvm8's bndarms trap).
#   * a missing/empty database is FATAL, never silently "no differences".
#   * an arm with ZERO golden call rows is FATAL for the same reason.
#   * cells that share a key (the DEF and ELAB copies of one source site) are
#     joined into ONE cell in SORTED order, so a collision cannot drop one.
set -u
: "${PRISTINE:?PRISTINE=<pristine slang-uhdm>}"
: "${PATCHED:?PATCHED=<patched slang-uhdm>}"
SRC=${1:?file.sv}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=${CEN:-/tmp/r10buvm16cen}
[ -x "$CEN" ] || { echo "FATAL no census $CEN (run build16.sh)"; exit 3; }
[ -x "$PRISTINE" ] || { echo "FATAL no PRISTINE $PRISTINE"; exit 3; }
[ -x "$PATCHED" ]  || { echo "FATAL no PATCHED $PATCHED"; exit 3; }
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/r10buvm16_grid_XXXXXX)
cp "$SRC" "$W/$B.sv"
cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -nocache -d coveruhdm > sl.log 2>&1
G=slpp_all/surelog.uhdm
[ -s "$G" ] || { echo "SURELOG_FAIL $B (wd=$W)"; tail -5 sl.log; exit 4; }
"$PRISTINE" "$B.sv" -o p.uhdm > p.log 2>&1
"$PATCHED"  "$B.sv" -o q.uhdm > q.log 2>&1
[ -s p.uhdm ] || { echo "SLANG_REJECT(pristine) $B (wd=$W)"; tail -5 p.log; exit 5; }
[ -s q.uhdm ] || { echo "SLANG_REJECT(patched) $B (wd=$W)"; tail -5 q.log; exit 5; }
raw() { # $1=db $2=tag -> key<TAB>cell, ONE ROW PER call
  "$CEN" "$1" "$2" > "$2.txt" 2>&1
  grep -q "^RESTORE_FAIL" "$2.txt" && { echo "FATAL restore $1" >&2; exit 6; }
  awk -v t="$2" '$1=="NEW" && $2==t {
      key=substr($3,5); $1=""; $2=""; $3="";
      sub(/^ +/,"");
      # DROP the sub=/sk=/si= DIAGNOSTIC TAIL: our functions carry no VpiFile,
      # so the enclosing-routine lookup answers ? on our side and prints the
      # name of the routine on the golden side -- not a binding difference.
      sub(/ sub=.*$/,"");
      print key "\t" $0 }' "$2.txt"
}
raw "$G" G > graw.txt; raw p.uhdm P > praw.txt; raw q.uhdm Q > qraw.txt
grp() { LC_ALL=C sort "$1" |
  awk -F'\t' '{ if ($1==k) { c=c " ,, " $2 } else { if (k!="") print k "\t" c; k=$1; c=$2 } }
              END { if (k!="") print k "\t" c }'; }
ng=$(wc -l < graw.txt)
echo "== grid $B   wd=$W   goldenNEWS=$ng pristine=$(wc -l < praw.txt) patched=$(wc -l < qraw.txt)"
[ "$ng" -gt 0 ] || { echo "FATAL arm $B has ZERO golden new-calls -- it tests nothing"; exit 7; }
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
