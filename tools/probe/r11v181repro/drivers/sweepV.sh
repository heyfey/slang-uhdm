#!/bin/bash
# sweepV.sh <binary> <workdir>
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
export SLANG_UHDM=$1
cd /tmp/wt_v11u181 && date > $2.log && tests/sweep.sh --jobs 3 --workdir $2 >> $2.log 2>&1; echo "rc=$?" >> $2.log; date >> $2.log
