#!/bin/bash
# sweep.sh <tree> <binary> <workdir> [corpus]  (v11u152)
. /tmp/v11u152_env.sh
export SLANG_UHDM=$2 STRICT_CMP=/tmp/v11u152_bin/uhdm-strictcmp
cd $1 && tests/sweep.sh --jobs 3 --workdir $3 ${4:+--corpus "$4"}
echo "SWEEP_RC=$?"
