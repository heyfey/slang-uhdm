#!/bin/bash
# rows.sh <binary> <workdir> <corpus> <filter-regex>  -> csv lines
source /tmp/r11u134_env.sh
export SLANG_UHDM=$1
cd /tmp/wt_r11u134 && python3 scripts/verify_golden.py --corpus $3 --mode both --jobs 3 --out $2.csv --workdir $2 --filter "$4" > $2.log 2>&1
cat $2.csv | grep -v '^name'
