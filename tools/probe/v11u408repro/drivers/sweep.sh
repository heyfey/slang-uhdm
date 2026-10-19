#!/bin/bash
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=/tmp/v11u408_bin/law.bin
export R11U408_TRACE=/tmp/v11u408_trace
unset GOLDEN_DEFER
mkdir -p $R11U408_TRACE
cd /tmp/wt_v11u408
date
tests/sweep.sh --jobs 3 --workdir /tmp/v11u408_lw --corpus "probe surelog uhdm2rtlil downstream"; echo "CORPUS_RC=$?"
date
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir /tmp/v11u408_lw/svtests --out /tmp/v11u408_lw/svtests.csv --svtests /home/heyfey/git-repos/sv-tests --baseline /tmp/v11u408_base_golden_svtests.csv; echo "SVTESTS_RC=$?"
date
