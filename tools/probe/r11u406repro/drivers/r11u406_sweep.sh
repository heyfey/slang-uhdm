#!/bin/bash
# usage: r11u406_sweep.sh <binary> <workdir>
# The four corpus stages from the worktree, then the sv-tests stage through the main tree's
# scripts/check_svtests.py read-only (a worktree has no UVM tree under third_party).
source /tmp/r11u406_env.sh
export SLANG_UHDM=$1 SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests
W=$2; mkdir -p $W
cd /tmp/wt_r11u406
tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W/sweep4.log 2>&1; echo "rc4=$?" >> $W/sweep4.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests $SVTESTS_ROOT > $W/svtests.log 2>&1; echo "rcsv=$?" >> $W/svtests.log
echo SWEEPDONE > $W/DONE
