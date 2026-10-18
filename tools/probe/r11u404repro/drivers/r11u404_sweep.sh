#!/bin/bash
# usage: r11u404_sweep.sh <binary> <workdir>
source /tmp/r11u404_env.sh
export SLANG_UHDM=$1 SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests
W=$2; mkdir -p $W
cd /tmp/wt_r11u404
tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W/sweep4.log 2>&1; echo "rc4=$?" >> $W/sweep4.log
while pgrep -af "sweep.sh|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests|svtests_matrix" | grep -v pgrep | grep -v r11u404 | grep -q .; do sleep 30; done
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests $SVTESTS_ROOT > $W/svtests.log 2>&1; echo "rcsv=$?" >> $W/svtests.log
echo SWEEPDONE > $W/DONE
