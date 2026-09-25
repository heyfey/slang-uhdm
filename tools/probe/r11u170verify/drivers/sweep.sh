#!/bin/bash
# sweep.sh <binary-or-wrapper> <workdir> [corpora]: the gate sweep from the r11u170 worktree with that binary.
source /tmp/wt_r11u170/tools/probe/r11u170verify/drivers/env.sh || exit 2
export SLANG_UHDM=$1; unset GOLDEN_DEFER
cd /tmp/wt_r11u170 && tests/sweep.sh --jobs 3 --workdir $2 ${3:+--corpus "$3"} > $2.log 2>&1
echo "sweep rc=$?" >> $2.log
