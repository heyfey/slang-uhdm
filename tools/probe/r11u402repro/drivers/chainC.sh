#!/bin/bash
waitfree(){ while pgrep -f 'check_[s]vtests|sweep[.]sh|verify_[g]olden|check_[p]robe|downstream_[u]hdm2rtlil' > /dev/null; do sleep 30; done; }
. /tmp/r11u402_env.sh
waitfree
rm -rf /tmp/r11u402_wdC; cd /tmp/wt_r11u402
SLANG_UHDM=/tmp/r11u402_bin/lawC tests/sweep.sh --jobs 3 --workdir /tmp/r11u402_wdC --corpus 'probe surelog uhdm2rtlil downstream' > /tmp/r11u402_sweepC.log 2>&1; echo EXIT $? >> /tmp/r11u402_sweepC.log
waitfree
cd /tmp; SLANG_UHDM=/tmp/r11u402_bin/lawC python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u402_wdC/svtests --out /tmp/r11u402_wdC/svtests.csv --svtests /home/heyfey/git-repos/sv-tests > /tmp/r11u402_svC.log 2>&1; echo EXIT $? >> /tmp/r11u402_svC.log
rm -rf /tmp/r11u402_cen_*
/tmp/r11u402_drivers/census402.sh /tmp/r11u402_wdP/surelog surelog /tmp/r11u402_bin/lawC /tmp/r11u402_cen_sl > /tmp/r11u402_censusC_surelog.txt 2>/dev/null
/tmp/r11u402_drivers/census402.sh /tmp/r11u402_wdP/uhdm2rtlil uhdm2rtlil /tmp/r11u402_bin/lawC /tmp/r11u402_cen_u2r > /tmp/r11u402_censusC_u2r.txt 2>/dev/null
echo CHAINDONE > /tmp/r11u402_chainC.done
