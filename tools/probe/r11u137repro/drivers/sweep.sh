#!/bin/bash
# sweep.sh <binary> <workdir> [corpora]
source /tmp/r11u137_env.sh
export SLANG_UHDM=$1
cd /tmp/wt_r11u137 && tests/sweep.sh --jobs 3 --workdir $2 --corpus "${3:-probe surelog uhdm2rtlil}" > $2.log 2>&1; echo "rc=$?" >> $2.log
