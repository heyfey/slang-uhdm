#!/bin/bash
# r11u116 sweep driver (sweep116.sh, copied from r11u114 sweep114.sh): <tag> <binary>; own workdir ${WDROOT}_<tag> (same-length tags)
TAG=${1:?tag}; BIN=${2:?binary}; W=${WDROOT:-/tmp/r11u116_wd}_$TAG
[ -e "$W" ] && { echo "refusing: $W exists"; exit 3; }
mkdir -p $W/sl $W/u2r
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
export SLANG_UHDM=$BIN
echo "BIN=$BIN md5=$(md5sum < $BIN)" > $W/BIN
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 3 --out $W/u2r_tf.csv --workdir $W/u2r > $W/u2r_tf.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode default --jobs 3 --out $W/u2r_def.csv --workdir $W/u2r > $W/u2r_def.log 2>&1
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out $W/sl.csv --workdir $W/sl > $W/sl.log 2>&1
echo DONE > $W/DONE
