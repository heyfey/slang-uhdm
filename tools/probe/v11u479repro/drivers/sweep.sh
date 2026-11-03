#!/bin/bash
# sweep.sh <binary> <workdir>: the five stages, four from the worktree, svtests through the main tree's tests/sweep.sh
B=$1; W=$2
source /tmp/v11u479_env.sh || exit 1
[ -x "$B" ] || exit 1
export SLANG_UHDM=$B SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests
unset GOLDEN_DEFER
mkdir -p $W
echo "BIN $B $(md5sum < $B)" > $W/cmdlog.txt
cd /tmp/wt_v11u479 && tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W/four.log 2>&1; echo "four rc=$?" >> $W/cmdlog.txt
cd /home/heyfey/git-repos/slang-uhdm && tests/sweep.sh --jobs 3 --workdir $W --corpus svtests > $W/sv.log 2>&1; echo "sv rc=$?" >> $W/cmdlog.txt
echo DONE >> $W/cmdlog.txt
