#!/bin/bash
# fullsweep.sh <binary> <workdir> <tracedir>: the ONE five-stage sweep on a binary (corpus stages
# from the worktree; the sv-tests stage through the main tree's scripts/check_svtests.py
# read-only with the baseline at this worktree's results/golden_svtests.csv, since a worktree
# has no UVM tree), with the pass trace on.
source /tmp/v11u426_env.sh
export SLANG_UHDM=$1 R11U426_TRACE=$3
[ -x "$SLANG_UHDM" ] || exit 2
mkdir -p $R11U426_TRACE
cd /tmp/wt_v11u426
echo "start $(date) $(md5sum < $SLANG_UHDM)"
tests/sweep.sh --jobs 3 --workdir $2 --corpus "probe surelog uhdm2rtlil downstream"
echo "corpus rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir $2/svtests --out $2/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u426/results/golden_svtests.csv
echo "svtests rc=$? $(date)"
