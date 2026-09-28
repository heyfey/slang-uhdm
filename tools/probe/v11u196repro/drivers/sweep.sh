#!/bin/bash
# v11u196: sweep.sh <binary tag in $V196_BIN: pris|law|fix> <workdir>: the gate sweep (tests/sweep.sh --jobs 3, all four
# stages) with the pins exported, run from the repo holding this driver.  The measured sweeps: pris from a worktree at
# b8719ea9 (/tmp/v11u196_swP), law from b8719ea9 + r11u196.patch (/tmp/v11u196_swL), fix from this tree (/tmp/v11u196_swF);
# same-length workdirs; each writes <workdir>.log ending in "sweep rc=N".
. "$(dirname "$0")/env.sh" || exit 3
export SLANG_UHDM=$V196_BIN/$1; W=$2
rm -rf $W; mkdir -p $W
( cd "$V196_REPO" && tests/sweep.sh --jobs 3 --workdir $W > $W.log 2>&1; echo "sweep rc=$?" >> $W.log )
