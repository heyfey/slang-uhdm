#!/bin/bash
# r10uvm47 (cloned from pass 46) (cloned from pass 45) (cloned from pass 44) — DETERMINISM check at the JOBS LEVEL THE BYTE VERIFIER USES.
#
# WHY THIS EXISTS.  This is the CONTROL for a byte-verifier difference: run ONE
# binary N times and count distinct hashes.  Two hashes from ONE binary means a
# byte difference between two binaries at that test is not evidence of a change.
#
# *** HEADER CORRECTED AT PASS 45 — DO NOT INHERIT THE OLD CLAIM. ***  This
# header used to assert that the `Scoreboard` flake is JOBS-DEPENDENT, on the
# strength of "3 identical hashes at --jobs 1, a difference at --jobs 4".  The
# pass-44 VERIFIER REFUTED that and it is not carried forward: `--jobs` is only
# verify_golden.py's TEST-LEVEL thread-pool width and this driver runs a single
# `--filter`ed test, so `--jobs 1` and `--jobs 4` are the IDENTICAL workload and
# that experiment cannot separate them.  The flake is INTRINSIC to one slang
# invocation (MEMORY.md's emitter-nondeterminism note: SourceLocation compares
# across macro buffers flip under slang's OWN parallel parse) and it is
# INTERMITTENT — which is exactly why one identical sample is not proof and why
# this driver takes N.  The `jobs` argument is kept only so a run can be made at
# the sweep's setting; it is not a variable the claim rests on.
#   usage: detcheck4.sh <TestName> <N> <jobs> [binary]
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
T=${1:?}
N=${2:-3}
J=${3:-4}
BIN=${4:-$ROOT/build/slang-uhdm}
for i in $(seq 1 "$N"); do
  WD=/tmp/r10uvm47_det4_${T}_$i
  rm -rf "$WD"
  SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog \
    --mode default --filter "^$T\$" --out "/tmp/r10uvm47_det4_${T}_$i.csv" \
    --workdir "$WD" --jobs "$J" > /dev/null 2>&1
  h=$(sha256sum "$WD"/default/$T-*/slang.uhdm 2>/dev/null | cut -c1-16)
  echo "run$i jobs=$J $h"
done
