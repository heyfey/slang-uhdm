#!/bin/bash
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=/tmp/v11u410_s/ver.bin
export R11U410_TRACE=/tmp/v11u410_s/trace_sweep
unset GOLDEN_DEFER
[ -x "$SLANG_UHDM" ] || { echo "no binary"; exit 9; }
mkdir -p $R11U410_TRACE /tmp/v11u410_wd
cd /tmp/wt_v11u410
bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u410_wd --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u410_s/sweep_main.log 2>&1
echo "main rc=$?" >> /tmp/v11u410_s/sweep_main.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir /tmp/v11u410_wd/svtests --out /tmp/v11u410_wd/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/wt_v11u410/results/golden_svtests.csv > /tmp/v11u410_s/sweep_sv.log 2>&1
echo "sv rc=$?" >> /tmp/v11u410_s/sweep_sv.log
