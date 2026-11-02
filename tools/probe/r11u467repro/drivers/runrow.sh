#!/bin/bash
# usage: runrow.sh <binary> <tag> <pathsfile>
source /tmp/r11u467_env.sh
[ -x "$1" ] || { echo no bin; exit 1; }
export SLANG_UHDM=$1
[ -n "$TRACE" ] && { export R11U467_TRACE=/tmp/r11u467_tr_$2; rm -rf $R11U467_TRACE; mkdir -p $R11U467_TRACE; }
rm -rf /tmp/r11u467_rw_$2
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out /tmp/r11u467_rr_$2.csv --workroot /tmp/r11u467_rw_$2 --jobs ${JOBS:-1} --paths-file $3 --keep-golden --uvm-dir third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > /tmp/r11u467_rr_$2.log 2>&1 </dev/null
tail -n +2 /tmp/r11u467_rr_$2.csv | cut -d, -f1,16,17,18
