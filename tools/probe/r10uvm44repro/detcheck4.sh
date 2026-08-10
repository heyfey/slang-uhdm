#!/bin/bash
# r10uvm44 — DETERMINISM check at the JOBS LEVEL THE BYTE VERIFIER USES.
#
# WHY THIS EXISTS.  Pass 41's detcheck.sh samples at `--jobs 1` and this pass
# ran it three times on `Scoreboard` with the POST binary: THREE IDENTICAL
# HASHES.  So the pass-41 statement "nondeterministic on every binary even at
# --jobs 1" did not reproduce here — but byteverify.sh sweeps at `--jobs 4` and
# Scoreboard DID differ there.  A determinism claim has to be made at the
# concurrency the measurement actually ran at; MEMORY.md's emitter-
# nondeterminism note (SourceLocation compares across macro buffers flipping
# under PARALLEL PARSE) predicts exactly that jobs-dependence.
#
# This is the CONTROL for a byte-verifier difference: run ONE binary N times at
# the same --jobs and count distinct hashes.  Two hashes from ONE binary means a
# byte difference between two binaries at that test is not evidence of a change.
#   usage: detcheck4.sh <TestName> <N> <jobs> [binary]
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
T=${1:?}
N=${2:-3}
J=${3:-4}
BIN=${4:-$ROOT/build/slang-uhdm}
for i in $(seq 1 "$N"); do
  WD=/tmp/r10uvm44_det4_${T}_$i
  rm -rf "$WD"
  SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog \
    --mode default --filter "^$T\$" --out "/tmp/r10uvm44_det4_${T}_$i.csv" \
    --workdir "$WD" --jobs "$J" > /dev/null 2>&1
  h=$(sha256sum "$WD"/default/$T-*/slang.uhdm 2>/dev/null | cut -c1-16)
  echo "run$i jobs=$J $h"
done
