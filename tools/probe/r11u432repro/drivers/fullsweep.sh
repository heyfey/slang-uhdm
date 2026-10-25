#!/bin/bash
# fullsweep.sh <law binary>: the pass's ONE five-stage sweep (corpus stages from the
# worktree, the sv-tests stage through the main tree's check_svtests.py read-only,
# since a worktree has no UVM tree) with the pass trace on.  The workdir name has
# the control's length (/tmp/intr11u430) for byteverify.
source /tmp/r11u432_env.sh
export SLANG_UHDM=$1
export R11U432_TRACE=/tmp/r11u432_trace
mkdir -p $R11U432_TRACE
[ -x "$SLANG_UHDM" ] || exit 2
cd /tmp/wt_r11u432
echo "start $(date)"
tests/sweep.sh --jobs 3 --workdir /tmp/r11u432sw1 --corpus "probe surelog uhdm2rtlil downstream"
echo "corpus rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u432sw1/svtests --out /tmp/r11u432sw1/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u432/results/golden_svtests.csv
echo "svtests rc=$? $(date)"
