#!/bin/bash
# usage: r11u402_run.sh <binary> <pathsfile> <tag>   -> /tmp/r11u402_sv_<tag>.csv, workroot /tmp/r11u402_svw_<tag>
. /tmp/r11u402_env.sh; export SLANG_UHDM=$1
rm -rf /tmp/r11u402_svw_$3 /tmp/r11u402_sv_$3.csv
cd /tmp/wt_r11u402 && python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out /tmp/r11u402_sv_$3.csv --workroot /tmp/r11u402_svw_$3 --jobs 3 --paths-file $2 --keep-golden --uvm-dir /home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0 2>&1 | tail -2
python3 -c "
import csv,sys
for x in csv.DictReader(open('/tmp/r11u402_sv_$3.csv')): print(x['path'],x['agreement'],x['slang_rc'],x['strict'][:60],x['slang_msg'][-60:])"
