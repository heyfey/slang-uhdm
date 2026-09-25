#!/bin/bash
# sweep.sh <binary> <workdir> [corpus list]: the gate sweep from the r11u162 worktree with a frozen binary
source /tmp/wt_r11u162/tools/probe/r11u162verify/drivers/env.sh
export SLANG_UHDM=$1; W=$2; shift 2
unset GOLDEN_DEFER
cd /tmp/wt_r11u162
if [ $# -gt 0 ]; then tests/sweep.sh --jobs 3 --workdir $W --corpus "$*"; else tests/sweep.sh --jobs 3 --workdir $W; fi
echo "SWEEP_RC=$?"
