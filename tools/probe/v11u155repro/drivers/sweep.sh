#!/bin/bash
# v11u155_sweep.sh <bin> <workdir> <corpora> <log>
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=$1 STRICT_CMP=/tmp/v11u155_bin/uhdm-strictcmp
unset GOLDEN_DEFER
cd /tmp/wt_v11u155pris && bash tests/sweep.sh --jobs 3 --workdir $2 --corpus "$3" > $4 2>&1
echo "rc=$?" >> $4
