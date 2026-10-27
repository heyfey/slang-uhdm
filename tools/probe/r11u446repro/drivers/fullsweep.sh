#!/bin/bash
source /tmp/r11u446_s/env.sh
export SLANG_UHDM=/tmp/r11u446_bin/law7
export R11U446_TRACE=/tmp/r11u446_trS
mkdir -p /tmp/r11u446_trS
cd /tmp/wt_r11u446
date > /tmp/r11u446_s/sweep_start.txt
bash tests/sweep.sh --jobs 3 --workdir /tmp/r11u446sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/r11u446_s/sweep_main.log 2>&1
echo "MAINRC=$?" >> /tmp/r11u446_s/sweep_main.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u446sw/svtests --out /tmp/r11u446sw/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u446/results/golden_svtests.csv > /tmp/r11u446_s/sweep_svtests.log 2>&1
echo "SVRC=$?" >> /tmp/r11u446_s/sweep_svtests.log
date > /tmp/r11u446_s/sweep_end.txt
