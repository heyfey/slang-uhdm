#!/bin/bash
# fullsweep.sh <binary> <workdir>: corpus stages from the worktree, then the sv-tests stage
# through the main tree's check_svtests.py (the worktree's UVM submodule is empty) against the
# worktree's golden_svtests.csv, on the same binary and workdir.
B=$1; W=$2
[ -x "$B" ] || { echo "no binary $B"; exit 2; }
source /tmp/v11u450_env.sh || exit 2
export SLANG_UHDM=$B
cd /tmp/wt_v11u450 || exit 2
rm -rf $W; mkdir -p $W
date > $W.start
bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W.corpus.log 2>&1
echo rc=$? >> $W.corpus.log
cd /home/heyfey/git-repos/slang-uhdm || exit 2
python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u450/results/golden_svtests.csv > $W.sv.log 2>&1
echo rc=$? >> $W.sv.log
date > $W.done
