#!/bin/bash
# v11u111 sweep: <tag> <binary>; workdir /tmp/v11u111_wd_<tag>
TAG=${1:?}; BIN=${2:?}; W=${WDROOT:-/tmp/v11u111_wd}_$TAG
[ -e "$W" ] && { echo "refusing $W"; exit 3; }
mkdir -p $W/sl $W/u2r
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
export SLANG_UHDM=$BIN
echo "BIN=$BIN md5=$(md5sum < $BIN)" > $W/BIN
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 3 --out $W/u2r_tf.csv --workdir $W/u2r > $W/u2r_tf.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default --jobs 3 --out $W/u2r_def.csv --workdir $W/u2r > $W/u2r_def.log 2>&1
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out $W/sl.csv --workdir $W/sl > $W/sl.log 2>&1
echo DONE > $W/DONE
