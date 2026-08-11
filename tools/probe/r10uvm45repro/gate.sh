#!/bin/bash
# r10uvm45 (cloned from pass 44) gate driver.  ALWAYS points SLANG_UHDM at THIS worktree's binary
# (verify_golden.py:52 and tests/check_goldens.sh:5 both default to the
# MAIN-TREE binary and a false pass is indistinguishable from a real one).
#   usage: gate.sh goldens <log>
#          gate.sh u2r   <out.csv> <workdir>
#          gate.sh sl    <out.csv> <workdir>            # surelog, both modes
#          gate.sh slbin <out.csv> <workdir> <binary>   # ditto, explicit binary
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
WHAT=${1:?}
shift
BIN=$ROOT/build/slang-uhdm
case "$WHAT" in
  goldens)
    LOG=${1:?}
    SLANG_UHDM=$BIN bash tests/check_goldens.sh > "$LOG" 2>&1
    echo "rc=$? PASS=$(grep -c '^PASS' "$LOG") FAIL=$(grep -c '^FAIL' "$LOG")"
    grep '^FAIL' "$LOG"
    ;;
  u2r)
    OUT=${1:?}; WD=${2:?}
    SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus uhdm2rtlil \
      --mode testflags --out "$OUT" --workdir "$WD" --jobs 4 2>&1 | tail -6
    ;;
  sl)
    OUT=${1:?}; WD=${2:?}
    SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog \
      --mode both --out "$OUT" --workdir "$WD" --jobs 4 2>&1 | tail -8
    ;;
  slbin)
    OUT=${1:?}; WD=${2:?}; B=${3:?}
    SLANG_UHDM=$B python3 scripts/verify_golden.py --corpus surelog \
      --mode both --out "$OUT" --workdir "$WD" --jobs 4 2>&1 | tail -8
    ;;
  *) echo "unknown: $WHAT"; exit 2;;
esac
