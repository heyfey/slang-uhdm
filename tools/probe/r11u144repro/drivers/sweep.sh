#!/bin/bash
# sweep.sh <binary> <workdir> <corpora...>
source /tmp/r11u144_env.sh
export SLANG_UHDM=$1; W=$2; shift 2
cd /tmp/wt_r11u144 && tests/sweep.sh --jobs 3 --workdir $W --corpus "$*" > $W.log 2>&1; echo "rc=$?" >> $W.log
