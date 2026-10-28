#!/bin/bash
source /tmp/r11u453_scr/env.sh || exit 2
export R11U453_TRACE=/tmp/r11u453_trace
cd /tmp/wt_r11u453
echo "start $(date)"
tests/sweep.sh --jobs 3 --workdir /tmp/r11u453_sw --corpus "probe surelog uhdm2rtlil downstream"
echo "corpus rc=$? $(date)"
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u453_sw/svtests --out /tmp/r11u453_sw/svtests.csv --svtests /home/heyfey/git-repos/sv-tests
echo "svtests rc=$? $(date)"
