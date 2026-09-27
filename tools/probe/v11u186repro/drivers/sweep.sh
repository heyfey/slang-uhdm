#!/bin/bash
# usage: v11u186_sweep.sh <tree> <bin> <workdir> [corpus...]
. /tmp/v11u186_env.sh || exit 3
T=$1; export SLANG_UHDM=$2; W=$3; shift 3
mkdir -p $W; cd $T
if [ $# -gt 0 ]; then tests/sweep.sh --jobs 3 --workdir $W --corpus "$*" > $W.log 2>&1; else tests/sweep.sh --jobs 3 --workdir $W > $W.log 2>&1; fi
echo "rc=$?" >> $W.log
