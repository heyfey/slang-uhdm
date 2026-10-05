#!/bin/bash
# (r11u239: copied from r11u231repro/drivers; the trace switch writes <pid>.239.)
# corpus.sh <binary> <workdir> [trace dir]: both corpora in both modes through the harness with --filter built from
# $FENCED (the four fenced tests never dispatched), R11U239_TRACE set when a trace dir is given. Not the gate sweep.
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$H/env.sh" || exit 2
b=$1; w=$2; t=$3; [ -x "$b" ] || exit 2
F="^(?!($(echo $FENCED | tr ' ' '|'))$)"
export SLANG_UHDM=$b STRICT_CMP=$B/uhdm-strictcmp; unset GOLDEN_DEFER
[ -n "$t" ] && { mkdir -p $t; export R11U239_TRACE=$t; }
mkdir -p $w
cd $REPO
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$F" --out $w/surelog.csv --workdir $w/surelog > $w/surelog.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$F" --out $w/uhdm2rtlil.csv --workdir $w/uhdm2rtlil > $w/uhdm2rtlil.log 2>&1
python3 scripts/compare_results.py $w/surelog.csv results/golden_surelog.csv --filter "$F" > $w/surelog.cmp 2>&1
python3 scripts/compare_results.py $w/uhdm2rtlil.csv results/golden_uhdm2rtlil.csv --filter "$F" > $w/uhdm2rtlil.cmp 2>&1
echo done > $w/DONE
