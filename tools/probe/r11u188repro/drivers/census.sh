#!/bin/bash
# r11u188: the firing census = the byte-mover PREDICTION, run (and frozen) before the gate sweep.  The law binary runs
# every corpus row-mode except the four fenced tests (--filter built from $FENCED, the FENCED= line of
# r11u107repro/canaudit.sh; env.sh fails closed) and every tests/probe case, with R11U188_TRACE=<dir>: each process
# writes `OUT <db path>` then one line per law firing (every branch of every r11u188 law that can write a field).
# usage: census.sh <law binary, absolute> <workdir>
set -eu
. "$(dirname "$0")/env.sh"
L=$1; W=$2; rm -rf $W; mkdir -p $W/tr
export SLANG_UHDM=$L R11U188_TRACE=$W/tr
cd "$R188_REPO"
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEGFENCE" --out $W/sl.csv --workdir $W/surelog > $W/sl.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEGFENCE" --out $W/u2r.csv --workdir $W/uhdm2rtlil > $W/u2r.log 2>&1
python3 scripts/check_probe.py --jobs 3 --workdir $W/probe --out $W/probe.csv > $W/probe.log 2>&1 || true
python3 "$(dirname "$0")/censum.py" $W/tr > $W/census.tsv
chmod -R a-w $W
echo CENSUS_DONE
