#!/bin/bash
# r10uvm121 — build every purpose-built golden arm with Surelog and with BOTH
# binaries, and score it (measurement only; the official uhdm-cmp is the judge
# and is also run per arm).
#   usage: PRISTINE=... PATCHED=... grid121.sh <outdir>
set -u
: "${PRISTINE:?}"; : "${PATCHED:?}"
OUT=${1:?outdir}
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
mkdir -p "$OUT"
for a in "$HERE"/g121_*.sv; do
  n=$(basename "$a" .sv)
  d="$OUT/$n"; rm -rf "$d"; mkdir -p "$d"; cp "$a" "$d/"
  ( cd "$d" && "$SURELOG" -parse -sverilog -d uhdm "$n.sv" > sl.log 2>&1; echo "surelog rc=$?" >> sl.log
    cp slpp_all/surelog.uhdm gold.uhdm 2>/dev/null
    "$PRISTINE" "$n.sv" --single-unit -o pris.uhdm > pris.log 2>&1; echo "rc=$?" >> pris.log
    "$PATCHED"  "$n.sv" --single-unit -o pat.uhdm  > pat.log  2>&1; echo "rc=$?" >> pat.log
    "$DUMP" gold.uhdm > gold.txt 2>&1
    "$DUMP" pris.uhdm > pris.txt 2>&1
    "$DUMP" pat.uhdm  > pat.txt  2>&1
    "$CMP" gold.uhdm pris.uhdm > cmp.pris.txt 2>&1; echo "pris cmp rc=$?" > CMP.txt
    "$CMP" gold.uhdm pat.uhdm  > cmp.pat.txt  2>&1; echo "pat  cmp rc=$?" >> CMP.txt
    echo "pris lines=$(wc -l < cmp.pris.txt) heads=$(grep -c '^LHS:' cmp.pris.txt; true)" >> CMP.txt
    echo "pat  lines=$(wc -l < cmp.pat.txt)  heads=$(grep -c '^LHS:' cmp.pat.txt; true)" >> CMP.txt
  ) </dev/null
  echo "===== $n"
  cat "$d/CMP.txt"
  ( cd "$HERE" && python3 score121.py "$d/gold.txt" "$d/pris.txt" "$d/pat.txt" "$d/$n.sv" )
done
