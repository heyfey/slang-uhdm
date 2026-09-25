#!/bin/bash
# sweepc.sh <binary> <workdir> [ENV=VAL ...]: the probe + both corpus stages only (no downstream), as sweep.sh.
. /tmp/r11u153_env.sh
b=$1; w=$2; shift 2
export SLANG_UHDM=$b
for kv in "$@"; do export "$kv"; done
cd /tmp/wt_r11u153 && tests/sweep.sh --jobs 3 --workdir $w --corpus "probe surelog uhdm2rtlil" > $w.log 2>&1
echo "SWEEP_RC=$?" >> $w.log
