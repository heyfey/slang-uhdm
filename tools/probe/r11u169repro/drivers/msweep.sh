#!/bin/bash
# msweep.sh <binary> <workdir> [ENV=VAL ...]: measurement sweep (probe + both corpora, no downstream)
D=$(cd $(dirname $0) && pwd); source $D/env.sh
export SLANG_UHDM=$1
W=$2; shift 2
for kv in "$@"; do export "$kv"; done
mkdir -p $W
cd $D/../../../.. && tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil" > $W.log 2>&1
echo "SWEEP_RC=$?" >> $W.log
