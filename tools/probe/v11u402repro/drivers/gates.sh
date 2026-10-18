#!/bin/bash
. /tmp/v11u402_env.sh
cd /tmp/wt_v11u402
log=/tmp/v11u402_gates.log
echo "start $(date)" >> $log
SLANG_UHDM=/tmp/v11u402_bin/law tests/sweep.sh --jobs 3 --workdir /tmp/v11u402_wdL --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u402_sweepL.log 2>&1; echo "law sweep rc=$? $(date)" >> $log
SLANG_UHDM=/tmp/v11u402_bin/pris tests/sweep.sh --jobs 3 --workdir /tmp/v11u402_wdP --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u402_sweepP.log 2>&1; echo "pris sweep rc=$? $(date)" >> $log
cd /home/heyfey/git-repos/slang-uhdm
SLANG_UHDM=/tmp/v11u402_bin/law python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/v11u402_svL --out /tmp/v11u402_svL.csv --svtests /home/heyfey/git-repos/sv-tests > /tmp/v11u402_svL.log 2>&1; echo "law sv rc=$? $(date)" >> $log
SLANG_UHDM=/tmp/v11u402_bin/pris python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/v11u402_svP --out /tmp/v11u402_svP.csv --svtests /home/heyfey/git-repos/sv-tests > /tmp/v11u402_svP.log 2>&1; echo "pris sv rc=$? $(date)" >> $log
echo done >> $log
