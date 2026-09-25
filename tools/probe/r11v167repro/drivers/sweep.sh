#!/bin/bash
# sweep.sh <worktree> <bin> <workdir> <corpora>
source ${ENVFILE:?export ENVFILE: the pin environment (SURELOG, UHDM_CMP, ..., FENCED)}
export SLANG_UHDM=$2 STRICT_CMP=/tmp/v11u167_bin/strictcmp
cd $1 && tests/sweep.sh --jobs 3 --workdir $3 --corpus "$4"
echo "SWEEP_RC=$?"
