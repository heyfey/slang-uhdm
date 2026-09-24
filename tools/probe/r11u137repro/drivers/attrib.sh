#!/bin/bash
# attrib.sh <corpus> <names-regex> <outdir> <env assignment|-> -> verify_golden run of the law binary on the named rows with one env switch
source /tmp/r11u137_env.sh; export SLANG_UHDM=${LAWBIN:-/tmp/r11u137_bin/l19}
c=$1; names=$2; A=$3; ev=$4
rm -rf $A; mkdir -p $A
cd /tmp/wt_r11u137
if [ "$ev" = - ]; then python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --out $A.csv --workdir $A --filter "^($names)\$" >/dev/null 2>&1
else env $ev python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --out $A.csv --workdir $A --filter "^($names)\$" >/dev/null 2>&1; fi
