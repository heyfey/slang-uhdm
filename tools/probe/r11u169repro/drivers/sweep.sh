#!/bin/bash
# sweep.sh <binary> <workdir> [corpora]: one gate sweep with the frozen binary
D=$(cd $(dirname $0) && pwd); source $D/env.sh
export SLANG_UHDM=$1
W=$2; shift 2
mkdir -p $W
cd $D/../../../.. && tests/sweep.sh --jobs 3 --workdir $W "$@" > $W.log 2>&1
echo "SWEEP_RC=$?" >> $W.log
