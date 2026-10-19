#!/bin/bash
# r11u411: the one full five-stage sweep on the final binary.  The four corpus
# stages run through the worktree's tests/sweep.sh; the sv-tests stage runs the
# main tree's scripts/check_svtests.py read-only (a worktree has no UVM tree),
# baseline the worktree's results/golden_svtests.csv (= the base's).
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=/tmp/r11u411_bin/final
export R11U411_TRACE=/tmp/r11u411_trace
WD=/tmp/r11u411_wd
rm -rf $WD /tmp/r11u411_trace; mkdir -p $WD /tmp/r11u411_trace
cd /tmp/wt_r11u411
date > /tmp/r11u411_sweep.times
bash tests/sweep.sh --jobs 3 --workdir $WD --corpus "probe surelog uhdm2rtlil downstream" > /tmp/r11u411_sweep.corpus.log 2>&1; echo "corpus rc=$?" >> /tmp/r11u411_sweep.corpus.log
date >> /tmp/r11u411_sweep.times
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $WD/svtests --out $WD/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u411/results/golden_svtests.csv > /tmp/r11u411_sweep.svtests.log 2>&1; echo "svtests rc=$?" >> /tmp/r11u411_sweep.svtests.log
date >> /tmp/r11u411_sweep.times
