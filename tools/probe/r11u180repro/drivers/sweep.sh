#!/bin/bash
# sweep.sh <binary> <workdir> : the full gate sweep (tests/sweep.sh --jobs 3, all four stages) with the pins exported
set -u
. /tmp/wt_r11u180/tools/probe/r11u180repro/drivers/env.sh || exit 2
export SLANG_UHDM=$1
W=$2; rm -rf $W; mkdir -p $W
cd /tmp/wt_r11u180 && tests/sweep.sh --jobs 3 --workdir $W > $W.log 2>&1
echo "sweep rc=$?" >> $W.log
