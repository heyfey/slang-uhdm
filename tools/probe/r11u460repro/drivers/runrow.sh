#!/bin/bash
# runrow.sh <bin> <tag> <listfile>: quiet check, then runner on listed sv-tests rows with kept goldens
B=$1; T=$2; L=$3
[ -x "$B" ] || { echo "no bin"; exit 1; }
/tmp/r11u460_scr/quiet.sh
cd /home/heyfey/git-repos/slang-uhdm && SLANG_UHDM=$B python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out /tmp/r11u460_scr/$T.csv --workroot /tmp/r11u460_w_$T --jobs 3 --paths-file $L --keep-golden --uvm-dir third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > /tmp/r11u460_scr/$T.log 2>&1
cut -d, -f1,17-19 /tmp/r11u460_scr/$T.csv
