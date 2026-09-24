#!/bin/bash
# rows.sh <binary> <outdir> <regex>  -> both corpora, both modes, the matching rows (verify_golden)
source /tmp/r11u130_env.sh
export SLANG_UHDM=$1; o=$2; f=$3
mkdir -p $o
cd /tmp/wt_r11u130
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --out $o/sl.csv --workdir $o/sl --filter "$f" >/dev/null 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --out $o/u2r.csv --workdir $o/u2r --filter "$f" >/dev/null 2>&1
cat $o/sl.csv $o/u2r.csv | grep -v '^name,' | sort
