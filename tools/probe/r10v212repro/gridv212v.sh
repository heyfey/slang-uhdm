#!/bin/bash
# r10v212 (VERIFIER) — THE TWO-VIEW JUDGE over the adversarial arms.
# MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
# sole judge and it is what this script runs.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# For each SUBDIRECTORY arm of `gridv/` it builds TWO goldens with the canonical
# golden-side Surelog (the one `scripts/verify_golden.py` names) —
#   definition view:  surelog -parse -sv design.sv
#   elaborated view:  surelog -parse -elabuhdm -sv design.sv
# — and compares each against the matching view of BOTH slang binaries
# (`design.sv` and `--elabuhdm design.sv`).  Counting follows
# `r10uvm67repro/rowheads.sh` EXACTLY: uhdm-cmp's stdout AND stderr are captured
# to one file, CMPLINES is `wc -l` of that file and HEADS is `grep -c '^LHS:'`.
# Counting only stdout gives a DIFFERENT number for the same run (46 where
# rowheads says 95) — a count is only comparable to counts taken the same way.
#
# GUARDS: subdirectory arms via `find` (a top-level glob runs nothing and prints
# green); arm list on fd 3, children `</dev/null`; PROCESSED asserted against
# LISTED; scratch keyed on the RELATIVE path; every rc recorded (verify_golden
# records rc=139 segfaults as SLANG_REJECT wearing the last stderr warning);
# both binaries named by PATH and md5.
#
#   usage: PRIS=<bin> PATCHED=<bin> OUT=<dir> gridv212v.sh
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
PRIS=${PRIS:?set PRIS to the frozen pristine binary}
PATCHED=${PATCHED:?set PATCHED to the frozen patched binary}
OUT=${OUT:?set OUT to the scratch directory for this run}
GRIDDIR=${GRIDDIR:-$HERE/gridv}
for x in "$SL" "$CMP" "$PRIS" "$PATCHED"; do
  [ -x "$x" ] || { echo "FATAL: not executable: $x"; exit 3; }
done
echo "SURELOG = $SL"
echo "PRIS    = $PRIS  md5=$(md5sum "$PRIS" | cut -c1-32)"
echo "PATCHED = $PATCHED  md5=$(md5sum "$PATCHED" | cut -c1-32)"
mkdir -p "$OUT" || exit 1
LIST=$OUT/arms.txt
find "$GRIDDIR" -mindepth 1 -maxdepth 1 -type d | sort > "$LIST"
listed=$(grep -c . "$LIST" || true)
echo "LISTED=$listed"
[ "$listed" -gt 0 ] || { echo "GATE FAIL: no arms under $GRIDDIR"; exit 4; }
printf "%-24s %-9s %-16s %-16s %-16s %-16s\n" ARM SLRC "DEF pris" "DEF patched" "ELAB pris" "ELAB patched"
proc=0
while read -r arm <&3; do
  rel=${arm#$GRIDDIR/}; key=$(echo "$rel" | tr '/' '_'); W=$OUT/$key
  mkdir -p "$W/d" "$W/e"
  cp "$arm/design.sv" "$W/d/"; cp "$arm/design.sv" "$W/e/"
  ( cd "$W/d" && "$SL" -parse -sv design.sv -mt 0 -mp 0 -o "$W/d" > sl.log 2>&1 </dev/null ); r1=$?
  ( cd "$W/e" && "$SL" -parse -elabuhdm -sv design.sv -mt 0 -mp 0 -o "$W/e" > sl.log 2>&1 </dev/null ); r2=$?
  row=""
  for k in d e; do
    if [ "$k" = d ]; then v=""; else v="--elabuhdm"; fi
    G=$(ls "$W/$k"/slpp_all/*.uhdm "$W/$k"/slpp_unit/*.uhdm 2>/dev/null | head -1)
    for b in "$PRIS" "$PATCHED"; do
      t=$(md5sum "$b" | cut -c1-8)
      ( cd "$W/$k" && "$b" $v design.sv -o "$t.uhdm" > "$t.log" 2>&1 </dev/null ); orc=$?
      if [ -n "$G" ] && [ -f "$G" ] && [ -f "$W/$k/$t.uhdm" ]; then
        "$CMP" "$G" "$W/$k/$t.uhdm" > "$W/$k/$t.cmp" 2>&1; crc=$?
        l=$(wc -l < "$W/$k/$t.cmp"); h=$(grep -c '^LHS:' "$W/$k/$t.cmp") || h=0
        row="$row $(printf '%-16s' "$l/$h,rc$crc")"
      else
        row="$row $(printf '%-16s' "NODB,rc$orc")"
      fi
    done
  done
  printf "%-24s %-9s%s\n" "$rel" "$r1/$r2" "$row"
  proc=$((proc+1))
done 3< "$LIST"
echo "PROCESSED=$proc LISTED=$listed"
[ "$proc" = "$listed" ] || { echo "GATE FAIL: PROCESSED != LISTED"; exit 4; }
echo "GRIDV2 OK"
