#!/bin/bash
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=/tmp/v11u470_bin/law R11U470_TRACE=/tmp/v11u470_trace
unset GOLDEN_DEFER
[ -x "$SLANG_UHDM" ] || exit 9
python3 /tmp/wt_v11u470/tools/probe/v11u470repro/drivers/quietwait.py
cd /tmp/wt_v11u470 && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u470_sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u470_sweep4.log 2>&1; echo "rc4=$?" >> /tmp/v11u470_sweep4.log
cd /home/heyfey/git-repos/slang-uhdm && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u470_sw --corpus svtests > /tmp/v11u470_sweepsv.log 2>&1; echo "rcsv=$?" >> /tmp/v11u470_sweepsv.log
