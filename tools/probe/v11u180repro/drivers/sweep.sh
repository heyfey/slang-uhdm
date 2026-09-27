#!/bin/bash
# sweep.sh <binary> <workdir> : full gate sweep from the verifier worktree
set -u
. /tmp/v11u180_scr/env.sh || exit 2
export SLANG_UHDM=$1 STRICT_CMP=/tmp/v11u180_bin/uhdm-strictcmp
W=$2; rm -rf $W; mkdir -p $W
cd /tmp/wt_v11u180 && tests/sweep.sh --jobs 3 --workdir $W > $W.log 2>&1
echo "sweep rc=$?" >> $W.log
