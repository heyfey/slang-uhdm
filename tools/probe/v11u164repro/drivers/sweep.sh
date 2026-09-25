#!/bin/bash
# usage: v11u164_sweep.sh <binary> <workdir> <worktree> [corpora]
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export STRICT_CMP=/tmp/v11u164_bin/uhdm-strictcmp
export SLANG_UHDM=$1
unset GOLDEN_DEFER
cd $3
if [ -n "$4" ]; then
  tests/sweep.sh --jobs 3 --workdir $2 --corpus "$4" > $2.log 2>&1
else
  tests/sweep.sh --jobs 3 --workdir $2 > $2.log 2>&1
fi
echo "SWEEP_RC=$?" >> $2.log
