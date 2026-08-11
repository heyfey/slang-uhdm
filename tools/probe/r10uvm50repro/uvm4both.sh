#!/bin/bash
# r10uvm50 — sweep the UVM-4 in BOTH modes into a named workdir, printing the
# binary md5 BEFORE and AFTER (never rebuild while a sweep runs).
#   usage: uvm4both.sh <out.csv> <workdir> [binary]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE"/../../.. && pwd)
OUT=${1:?}
WD=${2:?}
BIN=${3:-$ROOT/build/slang-uhdm}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
echo "BIN_MD5_BEFORE $(md5sum "$BIN")"
SLANG_UHDM=$BIN python3 "$ROOT/scripts/verify_golden.py" --corpus surelog \
  --mode both --filter '^(BuildUVMPkg|Scoreboard|SeqDriver|SimpleUVM)$' \
  --out "$OUT" --workdir "$WD" --jobs 2  # campaign standard is 2 while sibling worktrees are live (was 4) 2>&1 | tail -8
echo "BIN_MD5_AFTER  $(md5sum "$BIN")"
