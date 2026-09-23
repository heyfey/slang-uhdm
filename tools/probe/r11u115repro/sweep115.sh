#!/bin/bash
# sweep115.sh <binary> <tag>: both corpora, both modes, own workdir ${SWPWD:-/tmp/r11u115_swp}/<tag>
B=$1; T=$2; W=${SWPWD:-/tmp/r11u115_swp}/$T; mkdir -p $W
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
export SLANG_UHDM=$B
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --out $W/u2r.csv --workdir $W/u2r > $W/u2r.log 2>&1
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out $W/sl.csv --workdir $W/sl > $W/sl.log 2>&1
echo done > $W/DONE
