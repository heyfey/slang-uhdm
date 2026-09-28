#!/bin/bash
# v11u188: census.sh <binary> <out dir>: the firing census (R11U188_TRACE) over all tests/probe cases and both
# corpora in both modes, the four fenced rows excluded by --filter "$NEGFENCE".  Freeze <out dir> before the gate sweep.
. "$(dirname "$0")/env.sh" || exit 9
export SLANG_UHDM=$1; C=$2; rm -rf $C; mkdir -p $C/tr_sl $C/tr_u2r $C/tr_pr
cd "$V188_REPO"
R11U188_TRACE=$C/tr_pr python3 scripts/check_probe.py --jobs 3 --out $C/probe.csv --workdir $C/pw > $C/probe.log 2>&1
R11U188_TRACE=$C/tr_sl python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEGFENCE" --out $C/sl.csv --workdir $C/sl > $C/sl.log 2>&1
R11U188_TRACE=$C/tr_u2r python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEGFENCE" --out $C/u2r.csv --workdir $C/u2r > $C/u2r.log 2>&1
chmod -R a-w $C/tr_sl $C/tr_u2r $C/tr_pr
for c in sl u2r pr; do python3 "$(dirname "$0")/censum.py" $C/tr_$c; done > $C/census.txt
