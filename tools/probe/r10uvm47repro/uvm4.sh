#!/bin/bash
# r10uvm47 (cloned from pass 46) (cloned from pass 45) (cloned from pass 44) — sweep just the UVM-4 (default mode) into a named workdir so the
# metric panel can be measured PRE and POST on the SAME BOX with the two
# binaries' workdirs kept APART (the byte verifier deliberately shares one
# workdir; the metric panel must not).
#   usage: uvm4.sh <out.csv> <workdir> [binary]
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
OUT=${1:?}
WD=${2:?}
BIN=${3:-$ROOT/build/slang-uhdm}
SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog --mode default \
  --filter '^(BuildUVMPkg|Scoreboard|SeqDriver|SimpleUVM)$' \
  --out "$OUT" --workdir "$WD" --jobs 4 2>&1 | tail -6
