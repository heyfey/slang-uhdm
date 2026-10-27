#!/bin/bash
# fullsweep.sh <binary> <workdir> <tracedir>: the one five-stage sweep, trace on, from the worktree
B=$1; W=$2; T=$3; [ -x "$B" ] || { echo "no binary"; exit 2; }
source /tmp/r11u444_scratch/env.sh
export SLANG_UHDM=$B R11U444_TRACE=$T
mkdir -p $T
cd /tmp/wt_r11u444 && tests/sweep.sh --jobs 3 --workdir $W > $W.log 2>&1
echo "rc=$?" >> $W.log
