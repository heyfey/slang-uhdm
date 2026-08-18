#!/usr/bin/env bash
# r10buvm13repro/grid13.sh — THE THREE-WAY CELL TABLE for one arm, keyed on the
# question this pass owns: for a ref inside a FORMAL'S DEFAULT VALUE, does it
# carry `vpiActual`, and of WHAT KIND?
#
#   usage: PRISTINE=<bin> PATCHED=<bin> grid13.sh <file.sv>
#
# Cell value: <view>:act<0|1>-><actual kind>(<actual name>)
#             DEF and ELAB rows of ONE cell are joined with `,`, so a view
#             disagreement shows instead of colliding.
#             The actual is spelled by KIND and NAME, never by address, and
#             never by location: BaseClass::Compare reads VpiType/VpiName/
#             VpiDefName ONLY, so location is not a field the judge can see.
# Verdicts:   same / CONVERTED (P wrong, Q == G) / OVER-FIRE (P right, Q wrong)
#             / MOVED-STILL-WRONG / residue (G != P == Q, untouched)
#
# GUARDS, each an ops trap this campaign has paid for:
#   * Surelog AND BOTH binaries run in the SAME directory — a UHDM database
#     records the source file's ABSOLUTE path, so two CWDs make every object
#     differ (buvm8's bndarms trap).
#   * a missing/empty database is FATAL, never silently "no differences": an arm
#     that reaches nothing must not read as perfection.
#   * an arm with ZERO golden cells is FATAL for the same reason.
#   * the key is ID-BLIND and ADDRESS-BLIND; nothing in it depends on
#     allocation order.
#   * cells that share a key are joined into ONE cell in sorted order, so a
#     collision cannot silently drop one.
set -u
: "${PRISTINE:?PRISTINE=<pristine slang-uhdm>}"
: "${PATCHED:?PATCHED=<patched slang-uhdm>}"
SRC=${1:?file.sv}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/r10buvm13cen
[ -x "$CEN" ] || { echo "FATAL no census $CEN (run build13.sh)"; exit 3; }
[ -x "$PRISTINE" ] || { echo "FATAL no PRISTINE $PRISTINE"; exit 3; }
[ -x "$PATCHED" ]  || { echo "FATAL no PATCHED $PATCHED"; exit 3; }
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/r10buvm13_grid_XXXXXX)
cp "$SRC" "$W/$B.sv"
cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -nocache -d coveruhdm > sl.log 2>&1
G=slpp_all/surelog.uhdm
[ -s "$G" ] || { echo "SURELOG_FAIL $B (wd=$W)"; tail -5 sl.log; exit 4; }
"$PRISTINE" "$B.sv" -o p.uhdm > p.log 2>&1
"$PATCHED"  "$B.sv" -o q.uhdm > q.log 2>&1
[ -s p.uhdm ] || { echo "SLANG_REJECT(pristine) $B (wd=$W)"; tail -5 p.log; exit 5; }
[ -s q.uhdm ] || { echo "SLANG_REJECT(patched) $B (wd=$W)"; tail -5 q.log; exit 5; }
raw() { # $1=db $2=tag -> key<TAB>cell, ONE ROW PER OBJECT (ungrouped)
  "$CEN" "$1" "$2" > "$2.txt" 2>&1
  grep -q "^RESTORE_FAIL" "$2.txt" && { echo "FATAL restore $1" >&2; exit 6; }
  awk -v t="$2" '
    $1=="DV" && $2==t {
      key=""; act=""; ak=""; an="";
      for(i=1;i<=NF;i++){
        if($i ~ /^key=/) key=substr($i,5);
        else if($i ~ /^act=/)   act=substr($i,5);
        else if($i ~ /^akind=/) ak=substr($i,7);
        else if($i ~ /^aname=/) an=substr($i,7);
      }
      n=index(key,"|"); vw=substr(key,1,n-1); rest=substr(key,n+1);
      print rest "\t" vw ":act" act "->" ak "(" an ")" }' "$2.txt"
}
raw "$G" G > graw.txt; raw p.uhdm P > praw.txt; raw q.uhdm Q > qraw.txt
grp() { # $1=rawfile $2=1|0 locblind -> grouped key<TAB>cells
  if [ "$2" = 1 ]; then sed 's/@[0-9]*:[0-9]*\t/\t/' "$1"; else cat "$1"; fi |
  LC_ALL=C sort | awk -F'\t' '{ if ($1==k) { c=c "," $2 } else { if (k!="") print k "\t" c; k=$1; c=$2 } }
                              END { if (k!="") print k "\t" c }'
}
ng=$(wc -l < graw.txt)
echo "== grid $B   wd=$W   goldenCELLS=$ng pristine=$(wc -l < praw.txt) patched=$(wc -l < qraw.txt)"
[ "$ng" -gt 0 ] || { echo "FATAL arm $B has ZERO golden default-value ref cells -- it tests nothing"; exit 7; }
verdict() { # $1 = 0 location-keyed | 1 LOCATION-BLIND
  grp graw.txt "$1" > gk.txt; grp praw.txt "$1" > pk.txt; grp qraw.txt "$1" > qk.txt
  echo "-- keying: $([ "$1" = 1 ] && echo LOCATION-BLIND || echo location-keyed)"
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
}
# BOTH keyings are printed, and neither is allowed to stand alone: the
# LOCATION-KEYED verdict is the strict one, and the LOCATION-BLIND one is what
# separates THIS law's field from the pre-existing io_decl-LOCATION family (an
# extern PROTOTYPE listing whose default expression we write at the DEFINITION's
# line:col).  BaseClass::Compare reads VpiType/VpiName/VpiDefName only, so
# location is not a field the judge can see and the blind reading is the one
# that maps onto uhdm-cmp.
verdict 0
verdict 1
