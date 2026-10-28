#!/bin/bash
/tmp/wt_r11u452/tools/probe/r11u452repro/drivers/quiet.sh
cd /tmp/wt_r11u452 && source /tmp/r11u452_env.sh && export SLANG_UHDM=/tmp/r11u452_bin/law12
rm -rf /tmp/r11u452swp /tmp/r11u452_swtr; mkdir -p /tmp/r11u452_swtr
date > /tmp/r11u452_sweep.start
R11U452_TRACE=/tmp/r11u452_swtr bash tests/sweep.sh --jobs 3 --workdir /tmp/r11u452swp --corpus "probe surelog uhdm2rtlil downstream" > /tmp/r11u452_sweep.log 2>&1
echo rc=$? >> /tmp/r11u452_sweep.log
date > /tmp/r11u452_sweep.mid
/tmp/wt_r11u452/tools/probe/r11u452repro/drivers/quiet.sh
cd /home/heyfey/git-repos/slang-uhdm
R11U452_TRACE=/tmp/r11u452_swtr_sv python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u452swp/svtests --out /tmp/r11u452swp/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u452/results/golden_svtests.csv > /tmp/r11u452_sv.log 2>&1
echo rc=$? >> /tmp/r11u452_sv.log
date > /tmp/r11u452_sweep.done
