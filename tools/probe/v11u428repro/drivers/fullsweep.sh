#!/bin/bash
# fullsweep.sh <binary> <workdir> <tracedir>: one five-stage sweep (corpus stages from the
# worktree, the sv-tests stage through the main tree's check_svtests.py read-only, baseline
# the base's results/golden_svtests.csv). Workdir name has the control's length for byteverify.
source /tmp/wt_v11u428/tools/probe/v11u428repro/drivers/env.sh
export SLANG_UHDM=$1; W=$2
export R11U428_TRACE=$3
mkdir -p $R11U428_TRACE
[ -x "$SLANG_UHDM" ] || exit 2
cd /tmp/wt_v11u428
echo "start $(date)"
tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream"
echo "corpus rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u428/results/golden_svtests.csv
echo "svtests rc=$? $(date)"
