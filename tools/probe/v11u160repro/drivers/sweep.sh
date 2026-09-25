#!/bin/bash
# v11u160_sweep.sh <worktree> <binary> <workdir>
source $(dirname $0)/env.sh
export SLANG_UHDM=$2 STRICT_CMP=/tmp/v11u160_bin/uhdm-strictcmp
cd $1
tests/sweep.sh --jobs 3 --workdir $3
echo "SWEEP_RC=$?"
