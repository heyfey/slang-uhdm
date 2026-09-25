#!/bin/bash
# sweep.sh <binary> <workdir> [ENV=VAL ...]: the full gate (tests/sweep.sh --jobs 3, all stages) from this
# worktree with SLANG_UHDM=<binary>; any ENV=VAL (the law switches) reach every slang-uhdm run.
. /tmp/r11u153_env.sh
b=$1; w=$2; shift 2
export SLANG_UHDM=$b
for kv in "$@"; do export "$kv"; done
cd /tmp/wt_r11u153 && tests/sweep.sh --jobs 3 --workdir $w > $w.log 2>&1
echo "SWEEP_RC=$?" >> $w.log
