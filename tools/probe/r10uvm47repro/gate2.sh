#!/bin/bash
# r10uvm47 — the gate driver, --jobs 2 (a sibling worktree is live), always with
# SLANG_UHDM pinned to a binary named on the command line.  Both
# scripts/verify_golden.py:52 and tests/check_goldens.sh:5 DEFAULT SLANG_UHDM to
# the MAIN-TREE binary, and a false pass is indistinguishable from a real one.
#   usage: gate2.sh u2r <out.csv> <workdir> [binary]
#          gate2.sh sl  <out.csv> <workdir> [binary]     # surelog, --mode both
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WHAT=${1:?}
OUT=${2:?}
WD=${3:?}
BIN=${4:-$ROOT/build/slang-uhdm}
[ -x "$BIN" ] || { echo "FATAL: no binary at $BIN"; exit 3; }
echo "binary md5 BEFORE: $(md5sum "$BIN")"
case "$WHAT" in
  u2r)
    SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus uhdm2rtlil \
      --mode testflags --out "$OUT" --workdir "$WD" --jobs 2 2>&1 | tail -8
    ;;
  sl)
    SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog \
      --mode both --out "$OUT" --workdir "$WD" --jobs 2 2>&1 | tail -10
    ;;
  *) echo "unknown: $WHAT"; exit 2;;
esac
echo "binary md5 AFTER:  $(md5sum "$BIN")"
