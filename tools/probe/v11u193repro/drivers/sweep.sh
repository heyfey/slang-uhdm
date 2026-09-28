#!/bin/bash
# usage: sweep.sh <bin> <workdir> [corpora] ; runs from the verifier's law worktree
. "$(dirname "$0")/env.sh" || exit 3
export SLANG_UHDM=$1; W=$2; C=${3:-"probe surelog uhdm2rtlil downstream"}
cd $REPO && bash tests/sweep.sh --jobs 3 --workdir $W --corpus "$C"; echo "SWEEP_RC=$?"
