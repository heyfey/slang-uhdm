#!/bin/bash
# r11u186: sweep.sh <binary> <workdir> [corpora]: the gate sweep (tests/sweep.sh --jobs 3) with the pins exported.
set -u
. /tmp/wt_r11u186/tools/probe/r11u186repro/drivers/env.sh || exit 2
export SLANG_UHDM=$1
W=$2; rm -rf $W; mkdir -p $W
cd /tmp/wt_r11u186 && tests/sweep.sh --jobs 3 --workdir $W ${3:+--corpus "$3"} > $W.log 2>&1
echo "sweep rc=$?" >> $W.log
