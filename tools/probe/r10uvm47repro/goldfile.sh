#!/bin/bash
# r10uvm47 (cloned from pass 46) — golden for ONE arm FILE (gold.sh assumes the arm dir's dut.sv).
# Needed for a GOLDEN-ONLY cell: a source slang rejects can still be read on the
# Surelog side, and splitting it out of the arm keeps the rest comparable.
#   usage: goldfile.sh <source.sv> <outdir>
set -u
SRC=${1:?}
OUT=${2:?}
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$OUT" || exit 1
cd "$OUT" || exit 1
"$SL" -parse -d uhdm -nobuiltin "$SRC" > "$OUT/surelog.log" 2>&1
echo "surelog rc=$?"
ls -la "$OUT/slpp_all/surelog.uhdm" 2>/dev/null || { echo "FATAL: no database"; exit 3; }
