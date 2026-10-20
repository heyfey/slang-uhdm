#!/bin/bash
# v11u417 sweep.sh <binary> <workdir> : four stages from the worktree, then the sv-tests stage through the main tree's script (read-only)
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$1
export R11U417_TRACE=$2.trace; mkdir -p $R11U417_TRACE
unset GOLDEN_DEFER
cd /tmp/wt_v11u417 && bash tests/sweep.sh --jobs 3 --workdir $2 --corpus "probe surelog uhdm2rtlil downstream" > $2.log 2>&1
echo "four-stage rc=$?" >> $2.log
python3 /home/heyfey/git-repos/slang-uhdm/scripts/check_svtests.py --jobs 3 --workdir $2/svtests --out $2/svtests.csv --svtests /home/heyfey/git-repos/sv-tests > $2.svtests.log 2>&1
echo "svtests rc=$?" >> $2.svtests.log
