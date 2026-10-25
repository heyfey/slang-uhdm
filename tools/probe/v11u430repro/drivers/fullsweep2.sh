#!/bin/bash
# fullsweep2.sh <binary> <workdir> <tracedir>
# fullsweep.sh <law binary>: the pass's ONE five-stage sweep (corpus stages from the
# worktree, the sv-tests stage through the main tree's check_svtests.py read-only,
# since a worktree has no UVM tree), with the pass trace on.  Workdir name has the
# control's length (/tmp/intr11u426) for byteverify.
source /tmp/v11u430_scratch/env.sh
export SLANG_UHDM=$1
export R11U430_TRACE=$3
mkdir -p $R11U430_TRACE
[ -x "$SLANG_UHDM" ] || exit 2
cd /tmp/wt_v11u430
echo "start $(date)"
tests/sweep.sh --jobs 3 --workdir $2 --corpus "probe surelog uhdm2rtlil downstream"
echo "corpus rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir $2/svtests --out $2/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u430/results/golden_svtests.csv
echo "svtests rc=$? $(date)"
