#!/bin/bash
# row.sh <corpus> <regex> <bin> [tag]: run the harness on the named rows (both modes) with <bin>
source /tmp/r11u145_env.sh
c=$1; re=$2; b=$3; t=${4:-$(basename $b)}
W=/tmp/r11u145_rows/$t/$c; rm -rf $W; mkdir -p $W
cd /tmp/wt_r11u145 && SLANG_UHDM=$b python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --filter "$re" --out $W/out.csv --workdir $W/wd > $W/log 2>&1
tail -n +2 $W/out.csv | sort
