#!/usr/bin/env bash
# r10buvm17repro/grid17.sh — THE THREE-WAY CELL TABLE for one arm, keyed on the
# question this pass owns: what does each reference to a FOREACH LOOP VARIABLE
# carry as its vpiActual, and what object does the loop LIST?
#
#   usage: PRISTINE=<bin> PATCHED=<bin> grid17.sh <file.sv>
#
# Cell value: `view= lv= a=` from the census row -- the listing view, the whole
#             vpiLoopVars listing, and every loop-variable reference's
#             Actual_group.  IDs and ADDRESSES appear nowhere.
# Verdicts:   same / CONVERTED (P wrong, Q == G) / OVER-FIRE (P right, Q wrong)
#             / MOVED-STILL-WRONG / residue (G != P == Q, untouched)
#
# GUARDS (each an ops trap this campaign has paid for, carried from grid16.sh):
#   * Surelog AND BOTH binaries run in the SAME directory -- a UHDM database
#     records the source file's ABSOLUTE path, so two CWDs make every object
#     differ (buvm8's bndarms trap).
#   * a missing/empty database is FATAL, never silently "no differences".
#   * an arm with ZERO golden foreach rows is FATAL for the same reason.
#   * cells that share a key (the DEF and ELAB copies of one source site) are
#     joined into ONE cell in SORTED order, so a collision cannot drop one.
#   * the reference's PARENT KIND is kept in the cell but the census's own
#     `hk=`/`hi=`/`ch=`/`nref=` DIAGNOSTIC TAIL is dropped: our subroutines carry
#     different VpiFile/instance decorations, which says nothing about binding.
set -u
: "${PRISTINE:?PRISTINE=<pristine slang-uhdm>}"
: "${PATCHED:?PATCHED=<patched slang-uhdm>}"
SRC=${1:?file.sv}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=${CEN:-/tmp/r10buvm17cen}
[ -x "$CEN" ] || { echo "FATAL no census $CEN (run build17.sh)"; exit 3; }
[ -x "$PRISTINE" ] || { echo "FATAL no PRISTINE $PRISTINE"; exit 3; }
[ -x "$PATCHED" ]  || { echo "FATAL no PATCHED $PATCHED"; exit 3; }
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/r10buvm17_grid_XXXXXX)
cp "$SRC" "$W/$B.sv"
cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -nocache -d coveruhdm > sl.log 2>&1
G=slpp_all/surelog.uhdm
[ -s "$G" ] || { echo "SURELOG_FAIL $B (wd=$W)"; tail -5 sl.log; exit 4; }
"$PRISTINE" "$B.sv" -o p.uhdm > p.log 2>&1
"$PATCHED"  "$B.sv" -o q.uhdm > q.log 2>&1
[ -s p.uhdm ] || { echo "SLANG_REJECT(pristine) $B (wd=$W)"; tail -5 p.log; exit 5; }
[ -s q.uhdm ] || { echo "SLANG_REJECT(patched) $B (wd=$W)"; tail -5 q.log; exit 5; }
raw() { # $1=db $2=tag -> key<TAB>cell, ONE ROW PER foreach
  "$CEN" "$1" "$2" > "$2.txt" 2>&1
  grep -q "^RESTORE_FAIL" "$2.txt" && { echo "FATAL restore $1" >&2; exit 6; }
  awk -v t="$2" '$1=="FE" && $2==t {
      key=substr($3,5); sub(/\|\[.*/,"",key); sub(/\|<none>$/,"",key);
      $1=""; $2=""; $3="";
      sub(/^ +/,"");
      sub(/ hk=.*$/,"");
      sub(/ nref=[0-9]+/,"");
      print key "\t" $0 }' "$2.txt"
}
raw "$G" G > graw.txt; raw p.uhdm P > praw.txt; raw q.uhdm Q > qraw.txt
grp() { LC_ALL=C sort "$1" |
  awk -F'\t' '{ if ($1==k) { c=c " ,, " $2 } else { if (k!="") print k "\t" c; k=$1; c=$2 } }
              END { if (k!="") print k "\t" c }'; }
ng=$(wc -l < graw.txt)
echo "== grid $B   wd=$W   goldenFOREACH=$ng pristine=$(wc -l < praw.txt) patched=$(wc -l < qraw.txt)"
[ "$ng" -gt 0 ] || { echo "FATAL arm $B has ZERO golden foreach rows -- it tests nothing"; exit 7; }
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
