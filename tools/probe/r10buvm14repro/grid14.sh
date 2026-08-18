#!/usr/bin/env bash
# r10buvm14repro/grid14.sh — THE THREE-WAY CELL TABLE for one arm, keyed on the
# question this pass owns: what ELEMENT LIST does a hier_path carry?
#
#   usage: PRISTINE=<bin> PATCHED=<bin> grid14.sh <file.sv>
#
# Cell value: the hier_path's `name=… n=… mc=… nsel=… shape=…` row, i.e. every
#             element's KIND, vpiName and vpiFullName in order.  IDs and
#             ADDRESSES appear nowhere.
# Verdicts:   same / CONVERTED (P wrong, Q == G) / OVER-FIRE (P right, Q wrong)
#             / MOVED-STILL-WRONG / residue (G != P == Q, untouched)
#
# GUARDS, each an ops trap this campaign has paid for:
#   * Surelog AND BOTH binaries run in the SAME directory — a UHDM database
#     records the source file's ABSOLUTE path, so two CWDs make every object
#     differ (buvm8's bndarms trap).
#   * a missing/empty database is FATAL, never silently "no differences": an arm
#     that reaches nothing must not read as perfection.
#   * an arm with ZERO golden hier_path cells is FATAL for the same reason.
#   * cells that share a key (the DEF and ELAB copies of one source site) are
#     joined into ONE cell in sorted order, so a collision cannot silently drop
#     one.
#   * BOTH keyings are printed.  LOCATION-BLIND is the one that maps onto
#     uhdm-cmp (BaseClass::Compare reads VpiType/VpiName/VpiDefName only), and
#     the vpiFullName carried in `shape` is likewise NOT a field the judge sees
#     — it is printed so a fullname move is VISIBLE, not so it is counted.
set -u
: "${PRISTINE:?PRISTINE=<pristine slang-uhdm>}"
: "${PATCHED:?PATCHED=<patched slang-uhdm>}"
SRC=${1:?file.sv}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/r10buvm14cen
[ -x "$CEN" ] || { echo "FATAL no census $CEN (run build14.sh)"; exit 3; }
[ -x "$PRISTINE" ] || { echo "FATAL no PRISTINE $PRISTINE"; exit 3; }
[ -x "$PATCHED" ]  || { echo "FATAL no PATCHED $PATCHED"; exit 3; }
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/r10buvm14_grid_XXXXXX)
cp "$SRC" "$W/$B.sv"
cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -nocache -d coveruhdm > sl.log 2>&1
G=slpp_all/surelog.uhdm
[ -s "$G" ] || { echo "SURELOG_FAIL $B (wd=$W)"; tail -5 sl.log; exit 4; }
"$PRISTINE" "$B.sv" -o p.uhdm > p.log 2>&1
"$PATCHED"  "$B.sv" -o q.uhdm > q.log 2>&1
[ -s p.uhdm ] || { echo "SLANG_REJECT(pristine) $B (wd=$W)"; tail -5 p.log; exit 5; }
[ -s q.uhdm ] || { echo "SLANG_REJECT(patched) $B (wd=$W)"; tail -5 q.log; exit 5; }
raw() { # $1=db $2=tag -> key<TAB>cell, ONE ROW PER hier_path (ungrouped)
  "$CEN" "$1" "$2" > "$2.txt" 2>&1
  grep -q "^RESTORE_FAIL" "$2.txt" && { echo "FATAL restore $1" >&2; exit 6; }
  awk -v t="$2" '$1=="HP" && $2==t {
      key=substr($3,5); $1=""; $2=""; $3="";
      sub(/^ +/,""); print key "\t" $0 }' "$2.txt"
}
raw "$G" G > graw.txt; raw p.uhdm P > praw.txt; raw q.uhdm Q > qraw.txt
grp() { # $1=rawfile $2=1|0 name-keyed -> grouped key<TAB>cells
  # THE SECOND KEYING IS THE hier_path's OWN NAME, not a blanked location.
  # Blanking the location outright collapses a single-file arm into ONE bucket
  # and the verdict degenerates to "1 MOVED-STILL-WRONG" whatever happened --
  # measured on the first run of this script, and exactly the class of guard
  # this campaign keeps paying for.  VpiName IS a field BaseClass::Compare
  # reads, so a name-keyed join separates "the same written path moved shape"
  # from "a different object appeared", which is what the judge sees.
  if [ "$2" = 1 ]; then sed -E 's/^[^\t]*\t(name=[^ ]*) /\1\t\1 /' "$1"; else cat "$1"; fi |
  LC_ALL=C sort | awk -F'\t' '{ if ($1==k) { c=c " ,, " $2 } else { if (k!="") print k "\t" c; k=$1; c=$2 } }
                              END { if (k!="") print k "\t" c }'
}
ng=$(wc -l < graw.txt)
echo "== grid $B   wd=$W   goldenHIERPATHS=$ng pristine=$(wc -l < praw.txt) patched=$(wc -l < qraw.txt)"
[ "$ng" -gt 0 ] || { echo "FATAL arm $B has ZERO golden hier_paths -- it tests nothing"; exit 7; }
verdict() { # $1 = 0 location-keyed | 1 LOCATION-BLIND
  grp graw.txt "$1" > gk.txt; grp praw.txt "$1" > pk.txt; grp qraw.txt "$1" > qk.txt
  echo "-- keying: $([ "$1" = 1 ] && echo NAME-KEYED || echo location-keyed)"
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
verdict 0
verdict 1
