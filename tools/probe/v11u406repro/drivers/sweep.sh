#!/bin/bash
# sweep.sh <binary> <workdir> : four corpus stages from the verifier worktree, then sv-tests against the base baseline
source /tmp/v11u406_env.sh
export SLANG_UHDM=$1 SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests
W=$2; mkdir -p $W
cd /tmp/wt_v11u406
tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W/sweep4.log 2>&1; echo "rc4=$?" >> $W/sweep4.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests $SVTESTS_ROOT --baseline /tmp/wt_v11u406/results/golden_svtests.csv > $W/svtests.log 2>&1; echo "rcsv=$?" >> $W/svtests.log
echo SWEEPDONE > $W/DONE
