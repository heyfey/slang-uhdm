#!/bin/bash
# sweep.sh <binary> <workdir>: four corpus stages from the worktree, then the sv-tests stage
# through the main tree's tests/sweep.sh (the worktree's UVM folder is empty).
source /tmp/wt_v11u463/tools/probe/v11u463repro/drivers/env.sh || exit 1
export SLANG_UHDM=$1; [ -x "$SLANG_UHDM" ] || exit 1
WD=$2; unset GOLDEN_DEFER
cd /tmp/wt_v11u463 && bash tests/sweep.sh --jobs 3 --workdir $WD --corpus "probe surelog uhdm2rtlil downstream" > $WD.corpus.log 2>&1; echo "corpus rc=$?" >> $WD.corpus.log
cd /home/heyfey/git-repos/slang-uhdm && bash tests/sweep.sh --jobs 3 --workdir $WD --corpus svtests > $WD.svtests.log 2>&1; echo "svtests rc=$?" >> $WD.svtests.log
