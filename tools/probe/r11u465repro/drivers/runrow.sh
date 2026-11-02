#!/bin/bash
# usage: runpp.sh <binary> <tag>
source /tmp/r11u465_env.sh
export SLANG_UHDM=$1 R11U465_TRACE=/tmp/r11u465_tr_$2
rm -rf /tmp/r11u465_tr_$2 /tmp/r11u465_ppw_$2; mkdir -p $R11U465_TRACE
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out /tmp/r11u465_pp_$2.csv --workroot /tmp/r11u465_ppw_$2 --jobs 1 --paths-file ${3:-/tmp/r11u465_pp.lst} --keep-golden --uvm-dir third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > /tmp/r11u465_pp_$2.log 2>&1
tail -n +2 /tmp/r11u465_pp_$2.csv | cut -d, -f1,16,17,18
