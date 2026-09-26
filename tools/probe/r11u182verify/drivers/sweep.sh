#!/bin/bash
# sweep.sh <slang binary or state wrapper> <workdir> [corpora]: the gate sweep (tests/sweep.sh --jobs 3) from the
# r11u182 worktree with the pinned tools exported and SLANG_UHDM set to the given frozen binary.  Log: <workdir>.log.
source /tmp/wt_r11u182/tools/probe/r11u182verify/drivers/env.sh || exit 2
export SLANG_UHDM=$1; W=$2; C=${3:-}
cd /tmp/wt_r11u182
if [ -n "$C" ]; then tests/sweep.sh --jobs 3 --workdir $W --corpus "$C" > $W.log 2>&1
else tests/sweep.sh --jobs 3 --workdir $W > $W.log 2>&1; fi
echo "SWEEP_RC=$?" >> $W.log
