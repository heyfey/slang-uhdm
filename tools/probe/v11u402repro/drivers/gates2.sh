#!/bin/bash
. /tmp/v11u402_env.sh
cd /tmp/wt_v11u402
log=/tmp/v11u402_gates2.log
echo "start $(date)" >> $log
SLANG_UHDM=/tmp/v11u402_bin/fix2 tests/sweep.sh --jobs 3 --workdir /tmp/v11u402_wdF --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u402_sweepF.log 2>&1; echo "fix2 sweep rc=$? $(date)" >> $log
cd /home/heyfey/git-repos/slang-uhdm
SLANG_UHDM=/tmp/v11u402_bin/fix2 python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/v11u402_svF --out /tmp/v11u402_svF.csv --svtests /home/heyfey/git-repos/sv-tests > /tmp/v11u402_svF.log 2>&1; echo "fix2 sv rc=$? $(date)" >> $log
echo done >> $log
