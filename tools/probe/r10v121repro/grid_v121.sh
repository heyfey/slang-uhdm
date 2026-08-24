#!/usr/bin/env bash
# r10v121 — THE VERIFIER'S GRID DRIVER for § thisSuperNewAssignEmpty121.
# Compiles every v121_*.sv arm with the REAL Surelog and with BOTH binaries, in
# BOTH views (default and -elabuhdm), runs the OFFICIAL uhdm-cmp per arm, and
# scores it cell-by-cell with the implementer's score121.py (golden as truth).
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
#   usage: PRISTINE=... PATCHED=... grid_v121.sh <outdir>
#
# GUARDS: children get </dev/null; scratch is keyed on ARM+VIEW; every rc is
# recorded (verify_golden.py records rc=139 segfaults as SLANG_REJECT wearing a
# stale warning, so an arm driver must print rc itself).
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"
OUT=${1:?outdir}
HERE=$(cd "$(dirname "$0")" && pwd)
SCORE=${SCORE:-$HERE/../r10uvm121repro/score121.py}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
mkdir -p "$OUT"
for a in "$HERE"/v121_*.sv; do
  n=$(basename "$a" .sv)
  for V in def elab; do
    EF=""; SF=""
    [ "$V" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
    d="$OUT/$n.$V"; rm -rf "$d"; mkdir -p "$d"; cp "$a" "$d/"
    ( cd "$d" && "$SURELOG" -parse -sverilog $SF -d uhdm "$n.sv" > sl.log 2>&1
      echo "surelog rc=$?" >> sl.log
      cp slpp_all/surelog.uhdm gold.uhdm 2>/dev/null
      "$PRISTINE" "$n.sv" --single-unit $EF -o pris.uhdm > pris.log 2>&1; echo "PRIS_RC=$?" > RC.txt
      "$PATCHED"  "$n.sv" --single-unit $EF -o pat.uhdm  > pat.log  2>&1; echo "PAT_RC=$?" >> RC.txt
      "$DUMP" gold.uhdm > gold.txt 2>&1; "$DUMP" pris.uhdm > pris.txt 2>&1; "$DUMP" pat.uhdm > pat.txt 2>&1
      "$CMP" gold.uhdm pris.uhdm > cmp.pris.txt 2>&1; echo "pris cmp rc=$?" >> RC.txt
      "$CMP" gold.uhdm pat.uhdm  > cmp.pat.txt  2>&1; echo "pat  cmp rc=$?" >> RC.txt ) </dev/null
    echo "===== $n / $V   $(tr '\n' ' ' < "$d/RC.txt")"
    echo "      cmp lines pris=$(wc -l < "$d/cmp.pris.txt") pat=$(wc -l < "$d/cmp.pat.txt")  heads pris=$(grep -c '^LHS:' "$d/cmp.pris.txt"; true) pat=$(grep -c '^LHS:' "$d/cmp.pat.txt"; true)"
    [ -s "$d/gold.txt" ] && python3 "$SCORE" "$d/gold.txt" "$d/pris.txt" "$d/pat.txt" "$d/$n.sv" 2>&1 | tail -1
  done
done
