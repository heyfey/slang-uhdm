#!/bin/bash
# sweep.sh <binary> <workdir> : four stages from the worktree, then sv-tests via the main tree's runner (read-only)
. /tmp/r11u403_scr/env.sh
export R11U403_TRACE=${TRACEDIR:-} SLANG_UHDM=$1 SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests
W=$2; mkdir -p $W
cd /tmp/wt_r11u403
tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W/sweep4.log 2>&1; echo "rc4=$?" >> $W/sweep4.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests $SVTESTS_ROOT --baseline /tmp/wt_r11u403/results/golden_svtests.csv > $W/svtests.log 2>&1; echo "rcsv=$?" >> $W/svtests.log
