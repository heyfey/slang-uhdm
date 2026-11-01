#!/bin/bash
/tmp/r11u460_scr/quiet.sh
cd /tmp/wt_r11u460
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=/tmp/r11u460_bin/law12 R11U460_TRACE=/tmp/r11u460_trace
mkdir -p /tmp/r11u460_trace
tests/sweep.sh --jobs 3 --workdir /tmp/r11u460_sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/r11u460_scr/sweep.log 2>&1; echo "corpus rc=$?" >> /tmp/r11u460_scr/sweep.log
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir /tmp/r11u460_sw/svtests --out /tmp/r11u460_sw/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u460/results/golden_svtests.csv > /tmp/r11u460_scr/sweep_sv.log 2>&1
echo "svtests rc=$?" >> /tmp/r11u460_scr/sweep_sv.log
