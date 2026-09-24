#!/bin/bash
source /tmp/r11u137_env.sh
export SLANG_UHDM=$1
cd /tmp/wt_r11u137 && python3 scripts/downstream_uhdm2rtlil.py --jobs 3 --workdir $2 --out $2.csv --baseline results/downstream_uhdm2rtlil.csv > $2.log 2>&1; echo "rc=$?" >> $2.log
