#!/bin/bash
# v11u144_sweep.sh <bin> <workdir> <worktree> <corpora...>
source /tmp/v11u144_env.sh
export SLANG_UHDM=$1; W=$2; T=$3; shift 3
mkdir -p $W
cd $T && tests/sweep.sh --jobs 3 --workdir $W --corpus "$*" > $W.log 2>&1; echo "rc=$?" >> $W.log
