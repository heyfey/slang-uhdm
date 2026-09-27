#!/bin/bash
# r11u186: the firing census = the byte-mover PREDICTION, run before the gate sweep.  The law binary runs every
# corpus row-mode except the four fenced tests (--filter built from the FENCED= line of r11u107repro/canaudit.sh;
# fail closed) and every tests/probe case, with R11U183_TRACE=<dir> and R11U186_TRACE=<dir>: each process writes
# `OUT <db path>` then one line per law firing (TypeEmit/TaskFuncEmit/ModuleEmit/UhdmExporter units: .TE/.TF/.ME/.UX
# for the r11u183 laws, .186 for this pass's).  usage: census.sh <law bin name> <workdir>
set -eu
. /tmp/wt_r11u186/tools/probe/r11u186repro/drivers/env.sh
L=$1; W=$2; rm -rf $W; mkdir -p $W/tr
export SLANG_UHDM=/tmp/r11u186_bin/$L R11U183_TRACE=$W/tr R11U186_TRACE=$W/tr
cd /tmp/wt_r11u186
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NEGFENCE" --out $W/sl.csv --workdir $W/surelog > $W/sl.log 2>&1
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NEGFENCE" --out $W/u2r.csv --workdir $W/uhdm2rtlil > $W/u2r.log 2>&1
python3 scripts/check_probe.py --jobs 3 --workdir $W/probe --out $W/probe.csv > $W/probe.log 2>&1 || true
echo CENSUS_DONE
