#!/usr/bin/env bash
# r10v121 — INDEPENDENT ACQUITTAL of the boundary-differing arms that live
# OUTSIDE this pass's own probe directory.  Each arm is re-compiled ALONE with
# the REAL Surelog (both views) and scored cell-by-cell against that golden with
# the implementer's score121.py, golden as truth.  An arm is acquitted only when
# AWAY-GOLDEN == 0.
#   usage: PRISTINE=... PATCHED=... ROOT=<probe copy> acq_v121.sh <outdir> [rel ...]
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"; : "${ROOT:?probe root (a COPY)}"
OUT=${1:?outdir}; shift
HERE=$(cd "$(dirname "$0")" && pwd)
SCORE=${SCORE:-$HERE/../r10uvm121repro/score121.py}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
ARMS=("$@")
[ ${#ARMS[@]} -gt 0 ] || ARMS=(r10svs3repro/a2_thisnew.sv r10svs3repro/a3_position.sv \
  r10svs3repro/a4_ctorspan.sv r10svs3repro/a5_ctornest.sv r10svs4repro/v2_copy.sv \
  r10svs7repro/a3_context.sv r10uvm85repro/v85x9_misc.sv r10v110repro/v7_fence2.sv)
mkdir -p "$OUT"
for rel in "${ARMS[@]}"; do
  for V in def elab; do
    EF=""; SF=""; [ "$V" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
    # scratch keyed on the RELATIVE path: three different dut.sv exist in the tree
    key=$(printf '%s' "$rel" | tr '/' '_' | sed 's/\.sv$//')
    d="$OUT/$key.$V"; rm -rf "$d"; mkdir -p "$d"; cp "$ROOT/$rel" "$d/a.sv"
    ( cd "$d" && "$SURELOG" -parse -sverilog $SF -d uhdm a.sv > sl.log 2>&1
      cp slpp_all/surelog.uhdm gold.uhdm 2>/dev/null
      "$PRISTINE" a.sv --single-unit $EF -o pris.uhdm > pris.log 2>&1; echo "PRIS_RC=$?" > RC.txt
      "$PATCHED"  a.sv --single-unit $EF -o pat.uhdm  > pat.log  2>&1; echo "PAT_RC=$?" >> RC.txt
      "$DUMP" gold.uhdm > gold.txt 2>&1; "$DUMP" pris.uhdm > pris.txt 2>&1; "$DUMP" pat.uhdm > pat.txt 2>&1 ) </dev/null
    printf '%-38s %s\n' "$rel/$V" "$(python3 "$SCORE" "$d/gold.txt" "$d/pris.txt" "$d/pat.txt" "$d/a.sv" 2>&1 | tail -1)"
  done
done
