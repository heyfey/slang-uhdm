#!/bin/bash
# r11u411: after narrowing § pkgEnumCastTargetTs411 / § pkgAliasCastTargetTs411 to
# parameter declarations, the two stages the narrowed law reached (surelog and
# sv-tests, by the sweep-1 trace) rerun alone on the final binary.
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=/tmp/r11u411_bin/final2
export R11U411_TRACE=/tmp/r11u411_trace2
WD=/tmp/r11u411_w2
rm -rf $WD /tmp/r11u411_trace2; mkdir -p $WD /tmp/r11u411_trace2
cd /tmp/wt_r11u411
date > /tmp/r11u411_rerun.times
bash tests/sweep.sh --jobs 3 --workdir $WD --corpus surelog > /tmp/r11u411_rerun.surelog.log 2>&1; echo "surelog rc=$?" >> /tmp/r11u411_rerun.surelog.log
date >> /tmp/r11u411_rerun.times
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $WD/svtests --out $WD/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u411/results/golden_svtests.csv > /tmp/r11u411_rerun.svtests.log 2>&1; echo "svtests rc=$?" >> /tmp/r11u411_rerun.svtests.log
date >> /tmp/r11u411_rerun.times
