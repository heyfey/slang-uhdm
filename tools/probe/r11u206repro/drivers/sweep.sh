#!/bin/bash
# r11u206: the full gate sweep (tests/sweep.sh --jobs 3, all four stages) with the pins exported.
# usage: sweep.sh <binary (absolute)> <workdir>   (runs from the repo holding this script; the sweep dispatches every row itself)
set -u; HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
. "$HERE/env.sh" || exit 3
export SLANG_UHDM=$1; W=$2; mkdir -p $W; cd "$REPO"
unset GOLDEN_DEFER
tests/sweep.sh --jobs 3 --workdir $W > $W.log 2>&1; echo "SWEEP_RC=$?" >> $W.log
