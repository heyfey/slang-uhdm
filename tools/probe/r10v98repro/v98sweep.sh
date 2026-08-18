#!/bin/bash
# $1 = tag (pris|pat), $2 = binary, $3 = repo dir
set -u
TAG=$1; BIN=$2; REPO=$3
W=/tmp/v98_wd_$TAG
mkdir -p $W/u2r $W/sl
export SLANG_UHDM=$BIN
cd $REPO
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 --out $W/u2r_tf.csv --workdir $W/u2r > $W/u2r_tf.log 2>&1
echo "u2r_tf rc=$?" >> $W/done.log
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default --jobs 2 --out $W/u2r_def.csv --workdir $W/u2r > $W/u2r_def.log 2>&1
echo "u2r_def rc=$?" >> $W/done.log
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 2 --out $W/sl.csv --workdir $W/sl > $W/sl.log 2>&1
echo "sl rc=$?" >> $W/done.log
echo ALLDONE >> $W/done.log
