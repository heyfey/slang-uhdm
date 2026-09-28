#!/bin/bash
# v11u188: sweep.sh <binary, absolute> <workdir> [corpora]: tests/sweep.sh --jobs 3 with the pins exported, run from
# the repository holding this driver.  Same-length workdir names for byteverify (/tmp/v11u188_sw{P,L,V}).
. "$(dirname "$0")/env.sh" || exit 2
export SLANG_UHDM=$1; W=$2; rm -rf $W; mkdir -p $W
cd "$V188_REPO" && tests/sweep.sh --jobs 3 --workdir $W ${3:+--corpus "$3"} > $W.log 2>&1
echo "sweep rc=$?" >> $W.log
