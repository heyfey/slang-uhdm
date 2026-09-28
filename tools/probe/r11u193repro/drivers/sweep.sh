#!/bin/bash
# r11u193: sweep.sh <binary, absolute> <workdir> [corpora]: the gate sweep (tests/sweep.sh --jobs 3) with the pins exported,
# run from the repo holding this driver.
set -u
. "$(dirname "$0")/env.sh" || exit 2
export SLANG_UHDM=$1
W=$2; rm -rf $W; mkdir -p $W
cd "$R193_REPO" && tests/sweep.sh --jobs 3 --workdir $W ${3:+--corpus "$3"} > $W.log 2>&1
echo "sweep rc=$?" >> $W.log
