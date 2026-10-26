#!/bin/bash
# v11u436 fullsweep.sh <binary> <workdir> <tracedir>: four corpus stages from the worktree, the sv-tests stage through the main tree's scripts/check_svtests.py (a worktree has no UVM tree)
B=$1; W=$2; T=$3
source /tmp/v11u436_env.sh
export SLANG_UHDM=$B R11U436_TRACE=$T
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "missing $v"; exit 2; }; done
bash /tmp/v11u436_scr/quiet3.sh
mkdir -p $W $T; date
cd /tmp/wt_v11u436 && bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W.corpus.log 2>&1; echo "corpus stages rc=$?"; date
bash /tmp/v11u436_scr/quiet3.sh
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u436/results/golden_svtests.csv > $W.svtests.log 2>&1; echo "svtests stage rc=$?"; date
echo SWEEPDONE
