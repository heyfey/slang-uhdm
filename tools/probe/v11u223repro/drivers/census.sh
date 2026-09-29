#!/bin/bash
# v11u223 census: the law binary with R11U223_TRACE over every non-fenced corpus row-mode (both corpora, both modes),
# every probe case, and every downstream lane (fail closed on FENCED).
. "$(dirname "$0")/env.sh" || exit 3
W=${1:?workdir}; TR=$W/trace; mkdir -p $TR
NEG="^(?!($(echo $FENCED | tr ' ' '|'))$)"
export SLANG_UHDM=${SLANG_UHDM:-$B/law} R11U223_TRACE=$TR
cd $REPO
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEG" --out $W/sl.csv --workdir $W/surelog > $W/sl.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEG" --out $W/u2r.csv --workdir $W/uhdm2rtlil > $W/u2r.log 2>&1
python3 scripts/check_probe.py --jobs 3 --out $W/probe.csv --workdir $W/probe > $W/probe.log 2>&1
python3 scripts/downstream_uhdm2rtlil.py --jobs 3 --workdir $W/downstream --out $W/ds.csv --filter "$NEG" > $W/ds.log 2>&1
echo CENSUS_DONE > $W/done
