#!/bin/bash
# v11u209: sweep.sh <binary> <workdir> [corpus list] -- the gate sweep (tests/sweep.sh --jobs 3) from this repository
# with SLANG_UHDM=<binary>, GOLDEN_DEFER unset.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
export SLANG_UHDM=$1; unset GOLDEN_DEFER
cd $REPO
if [ -n "$3" ]; then tests/sweep.sh --jobs 3 --workdir $2 --corpus "$3"; else tests/sweep.sh --jobs 3 --workdir $2; fi
echo "SWEEP_RC=$?"
