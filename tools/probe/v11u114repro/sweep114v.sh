#!/bin/bash
# v11u114 sweep: <tag> <binary>; workdir ${WDROOT:-/tmp/v11u114_wd}_<tag>; <PHASE>=u2r|sl|all
TAG=${1:?tag}; BIN=${2:?bin}; PHASE=${3:-all}; W=${WDROOT:-/tmp/v11u114_wd}_$TAG
mkdir -p $W/sl $W/u2r
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
export SLANG_UHDM=$BIN
echo "BIN=$BIN md5=$(md5sum < $BIN)" > $W/BIN
if [ $PHASE = u2r ] || [ $PHASE = all ]; then
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 3 --out $W/u2r_tf.csv --workdir $W/u2r > $W/u2r_tf.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default --jobs 3 --out $W/u2r_def.csv --workdir $W/u2r > $W/u2r_def.log 2>&1
echo DONE > $W/DONE_u2r
fi
if [ $PHASE = sl ] || [ $PHASE = all ]; then
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out $W/sl.csv --workdir $W/sl > $W/sl.log 2>&1
echo DONE > $W/DONE_sl
fi
