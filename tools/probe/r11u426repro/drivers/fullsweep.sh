#!/bin/bash
# fullsweep.sh <law binary>: the pass's ONE five-stage sweep (corpus stages from the
# worktree, the sv-tests stage through the main tree's check_svtests.py read-only,
# since a worktree has no UVM tree), with the pass trace on.
source /tmp/r11u426_scratch/env.sh
export SLANG_UHDM=$1
export R11U426_TRACE=/tmp/r11u426_scratch/trace
mkdir -p $R11U426_TRACE
[ -x "$SLANG_UHDM" ] || exit 2
cd /tmp/wt_r11u426
echo "start $(date)"
tests/sweep.sh --jobs 3 --workdir /tmp/r11u426wd --corpus "probe surelog uhdm2rtlil downstream"
echo "corpus rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u426wd/svtests --out /tmp/r11u426wd/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u426/results/golden_svtests.csv
echo "svtests rc=$? $(date)"
