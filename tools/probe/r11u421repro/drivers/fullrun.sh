#!/bin/bash
# r11u421 the one full five-stage sweep on the final law binary
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=/tmp/r11u421_law.bin
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "no $v"; exit 9; }; done
[ "$(md5sum < $SLANG_UHDM | cut -c1-32)" = 22d95ce83451d22560ae8990578e4ff7 ] || { echo "wrong binary"; exit 9; }
/tmp/r11u421_bin/quiet.sh || exit 8
export R11U421_TRACE=/tmp/r11u421_trsw; rm -rf $R11U421_TRACE; mkdir -p $R11U421_TRACE
W=/tmp/r11u421_sw; rm -rf $W; mkdir -p $W
cd /tmp/wt_r11u421 && date > $W/start.txt
bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W/sweep_corpus.log 2>&1; echo "corpus rc=$?" >> $W/sweep_corpus.log
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/check_svtests.py --jobs 3 --workdir $W/svtests --out $W/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_r11u421/results/golden_svtests.csv > $W/svtests_stage.log 2>&1; echo "svtests rc=$?" >> $W/svtests_stage.log
date > $W/end.txt
