#!/bin/bash
# usage: fullsweep.sh <binary> <workdir (15 chars, the control's length)> <trace dir>
# four corpus stages through the worktree's tests/sweep.sh, the sv-tests stage through
# the main tree's scripts/check_svtests.py with the worktree's baseline (the worktree's
# UVM submodule is empty; scripts/ identical between base and main tree)
source /tmp/v11u441_env.sh || exit 2
B=$1; W=$2; T=$3
[ -x "$B" ] || { echo "missing $B"; exit 2; }
export SLANG_UHDM=$B R11U441_TRACE=$T
mkdir -p $T $W
date; echo "binary $(md5sum < $B)"
cd /tmp/wt_v11u441
bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W.corpus.log 2>&1
echo "corpus rc=$?"; date
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u441/results/golden_svtests.csv > $W.svtests.log 2>&1
echo "svtests rc=$?"; date
