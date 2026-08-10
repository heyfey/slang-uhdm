#!/bin/bash
# r10uvm41 — DETERMINISM check on one surelog-suite test: N sweeps of the same
# binary into fresh workdirs, distinct slang.uhdm hashes counted.
#   usage: detcheck.sh <TestName> <N> [binary]
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
T=${1:?}
N=${2:-3}
BIN=${3:-$ROOT/build/slang-uhdm}
for i in $(seq 1 "$N"); do
  WD=/tmp/r10uvm41_det_${T}_$i
  rm -rf "$WD"
  SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog \
    --mode default --filter "^$T\$" --out "/tmp/r10uvm41_det_${T}_$i.csv" \
    --workdir "$WD" --jobs 1 > /dev/null 2>&1
  h=$(sha256sum "$WD"/default/$T-*/slang.uhdm 2>/dev/null | cut -c1-16)
  echo "run$i $h"
done
