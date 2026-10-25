#!/bin/bash
# fullsweep.sh <binary> <workdir> <tracedir>: the five stages once (corpus stages from the
# worktree; sv-tests through the main tree's check_svtests.py, read-only, baseline the base's golden)
source /tmp/v11u432_env.sh
export SLANG_UHDM=$1; W=$2; export R11U432_TRACE=$3; export R11V432_TRACE=$3
[ -x "$SLANG_UHDM" ] || exit 2
mkdir -p $R11U432_TRACE
bash /tmp/wt_v11u432/tools/probe/v11u432repro/drivers/quiet.sh
cd /tmp/wt_v11u432
echo "start $(date)"
tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream"
echo "corpus rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u432/results/golden_svtests.csv
echo "svtests rc=$? $(date)"
