#!/bin/bash
# v11u178_sweep.sh <binary> <workdir> [ENV=VAL...]  full gate sweep from the patched worktree (HEAD harness)
b=$1; w=$2; shift 2
EXTRA=("$@")
source /tmp/v11u178_env.sh
export SLANG_UHDM=$b
unset GOLDEN_DEFER
cd /tmp/wt_v11u178
env "${EXTRA[@]}" tests/sweep.sh --jobs 3 --workdir $w ${CORP:+--corpus "$CORP"} > $w.log 2>&1
echo "rc=$?" >> $w.log
