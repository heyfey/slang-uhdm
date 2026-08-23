#!/usr/bin/env bash
# r10v113 grid driver — golden (Surelog) vs PRISTINE vs PATCHED for one arm, in
# BOTH views.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#   view "default": surelog -parse           |  ours  <src> --single-unit
#   view "elab"   : surelog -parse -elabuhdm |  ours  <src> --single-unit --elabuhdm
# Every cell records rc.  SUR defaults to the binary scripts/verify_golden.py
# uses (~/git-repos/Surelog) — the sv-tests copy on $PATH is a DIFFERENT build
# whose small-design func_calls carry NO vpiParent and census to nothing.
set -u
SUR=${SUR:-$HOME/git-repos/Surelog/build/bin/surelog}
PRIS=${PRIS:?}; PAT=${PAT:?}; CEN=${CEN:?}
SCORE=${SCORE:-$(dirname "$0")/../r10uvm113repro/score113.py}
ARM=${1:?arm.sv}
OUT=${OUT:-/tmp/v113_grid}/$(basename "$ARM" .sv)
rm -rf "$OUT"; mkdir -p "$OUT/o"
cp "$ARM" "$OUT/o/a.sv"
for v in default elab; do
  SEF=""; OEF=""
  [ "$v" = elab ] && { SEF="-elabuhdm"; OEF="--elabuhdm"; }
  mkdir -p "$OUT/g_$v"
  ( cd "$OUT/o" && "$SUR" -parse $SEF a.sv -mt 0 -mp 0 -o "$OUT/g_$v" > sur.$v.log 2>&1; echo "rc=$?" >> sur.$v.log ) </dev/null
  ( cd "$OUT/o" && "$PRIS" a.sv --single-unit $OEF -o p.$v.uhdm > p.$v.log 2>&1; echo "rc=$?" >> p.$v.log ) </dev/null
  ( cd "$OUT/o" && "$PAT"  a.sv --single-unit $OEF -o q.$v.uhdm > q.$v.log 2>&1; echo "rc=$?" >> q.$v.log ) </dev/null
  G=$(ls "$OUT/g_$v"/slpp_all/*.uhdm 2>/dev/null | head -1)
  echo "-- $(basename "$ARM") view=$v  sur=$(tail -1 "$OUT/o/sur.$v.log") pris=$(tail -1 "$OUT/o/p.$v.log") pat=$(tail -1 "$OUT/o/q.$v.log")"
  [ -n "$G" ] || { echo "   NO GOLDEN"; continue; }
  [ -s "$OUT/o/p.$v.uhdm" ] || { echo "   PRIS REJECT"; continue; }
  [ -s "$OUT/o/q.$v.uhdm" ] || { echo "   PATCHED REJECT"; continue; }
  "$CEN" "$G"              | LC_ALL=C sort > "$OUT/g.$v.tsv"
  "$CEN" "$OUT/o/p.$v.uhdm"| LC_ALL=C sort > "$OUT/p.$v.tsv"
  "$CEN" "$OUT/o/q.$v.uhdm"| LC_ALL=C sort > "$OUT/q.$v.tsv"
  python3 "$SCORE" "$OUT/g.$v.tsv" "$OUT/p.$v.tsv" "$OUT/q.$v.tsv" "$(basename "$ARM" .sv)/$v"
done
