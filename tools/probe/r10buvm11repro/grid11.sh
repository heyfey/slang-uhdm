#!/usr/bin/env bash
# r10buvm11repro/grid11.sh — THE THREE-WAY CELL TABLE for one arm, keyed on the
# question this pass owns: for every `array_var`, what does its ELEMENT variable
# (vpiReg) carry under `vpiRange`, and does it match the array_var's own?
#
#   usage: PRISTINE=<bin> PATCHED=<bin> grid11.sh <file.sv>
#
# Cell value: at<arrayType>|av<marker shape>|<element kind>|ev<marker shape>
#             where `-` = the field is absent (null vector) and `()` = present
#             but EMPTY.  DEF and ELAB rows of one declaration are joined with
#             `,` into ONE cell, so a view disagreement is visible in the cell.
# Verdicts:   same / CONVERTED (P wrong, Q == G) / OVER-FIRE (P right, Q wrong)
#             / MOVED-STILL-WRONG / residue (G != P == Q, untouched)
#
# GUARDS, each an ops trap this campaign has paid for:
#   * Surelog AND BOTH binaries run in the SAME directory — a UHDM database
#     records the source file's ABSOLUTE path, so two CWDs make every object
#     differ (buvm8's bndarms trap).
#   * a missing/empty database is FATAL, never silently "no differences": an arm
#     that reaches nothing must not read as perfection.
#   * the key is ID-BLIND and ADDRESS-BLIND, so nothing in it can depend on
#     allocation order; object IDENTITY (Surelog hands the element the array's
#     own vector) is REPORTED but is NOT part of any cell, because uhdm-cmp does
#     not compare identity and a law must not be judged on a field the judge
#     cannot see.
set -u
: "${PRISTINE:?PRISTINE=<pristine slang-uhdm>}"
: "${PATCHED:?PATCHED=<patched slang-uhdm>}"
SRC=${1:?file.sv}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/r10buvm11cen
[ -x "$CEN" ] || { echo "FATAL no census $CEN (run build11.sh)"; exit 3; }
[ -x "$PRISTINE" ] || { echo "FATAL no PRISTINE $PRISTINE"; exit 3; }
[ -x "$PATCHED" ]  || { echo "FATAL no PATCHED $PATCHED"; exit 3; }
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/r10buvm11_grid_XXXXXX)
cp "$SRC" "$W/$B.sv"
cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -nocache -d coveruhdm > sl.log 2>&1
G=slpp_all/surelog.uhdm
[ -s "$G" ] || { echo "SURELOG_FAIL $B (wd=$W)"; tail -5 sl.log; exit 4; }
"$PRISTINE" "$B.sv" -o p.uhdm > p.log 2>&1
"$PATCHED"  "$B.sv" -o q.uhdm > q.log 2>&1
[ -s p.uhdm ] || { echo "SLANG_REJECT(pristine) $B (wd=$W)"; tail -5 p.log; exit 5; }
[ -s q.uhdm ] || { echo "SLANG_REJECT(patched) $B (wd=$W)"; tail -5 q.log; exit 5; }
one() { # $1=db $2=tag -> key<TAB>cell
  "$CEN" "$1" "$2" > "$2.txt" 2>&1
  grep -q "^RESTORE_FAIL" "$2.txt" && { echo "FATAL restore $1" >&2; exit 6; }
  awk -v t="$2" '
    $1=="AV" && $2==t {
      vw=""; key=""; at=""; avm=""; ek=""; evm="";
      for(i=1;i<=NF;i++){
        if($i ~ /^view=/) vw=substr($i,6);
        else if($i ~ /^key=/) key=substr($i,5);
        else if($i ~ /^at=/)  at=substr($i,4);
        else if($i ~ /^avM=/) avm=substr($i,5);
        else if($i ~ /^ek=/)  ek=substr($i,4);
        else if($i ~ /^evM=/) evm=substr($i,5);
      }
      # the KEY is the declaration; the VIEW rides in the CELL so a DEF/ELAB
      # disagreement shows up instead of colliding two objects into one row.
      print key "\t" vw ":at" at "|av" avm "|" ek "|ev" evm }' "$2.txt" |
  LC_ALL=C sort | awk -F'\t' '{ if ($1==k) { c=c "," $2 } else { if (k!="") print k "\t" c; k=$1; c=$2 } }
                              END { if (k!="") print k "\t" c }'
}
one "$G" G > gk.txt; one p.uhdm P > pk.txt; one q.uhdm Q > qk.txt
echo "== grid $B   wd=$W   goldenAV=$(wc -l < gk.txt) pristine=$(wc -l < pk.txt) patched=$(wc -l < qk.txt)"
echo "-- identity (golden): $(grep -c 'shared=1' G.txt; true) element vectors ARE the array_var's own object"
LC_ALL=C join -t$'\t' -a1 -a2 -e - -o 0,1.2,2.2 -j1 gk.txt pk.txt > gp.txt
LC_ALL=C join -t$'\t' -a1 -a2 -e - -o 0,1.2,1.3,2.2 -j1 gp.txt qk.txt |
awk -F'\t' '{
  v = ($2==$3 && $3==$4) ? "same" :
      ($2!=$3 && $2==$4) ? "CONVERTED" :
      ($2==$3 && $2!=$4) ? "OVER-FIRE" :
      ($2!=$3 && $2!=$4 && $3!=$4) ? "MOVED-STILL-WRONG" : "residue";
  c[v]++;
  if (v!="same") printf "%-18s %s\n   G=%s\n   P=%s\n   Q=%s\n", v, $1, $2, $3, $4 }
  END { printf "-- "; for (k in c) printf "%s=%d ", k, c[k]; printf "\n" }'
