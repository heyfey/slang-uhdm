#!/bin/bash
# rowstep.sh <tag>: run param_vif row on /tmp/r11u476_bin/slang-uhdm.<tag>, simulate the sister param_assign face, strict head
source /tmp/r11u476_env.sh || exit 1
T=$1; cd /home/heyfey/git-repos/slang-uhdm
rm -rf /tmp/r11u476_sv$T /tmp/r11u476_p_$T.csv
SLANG_UHDM=/tmp/r11u476_bin/slang-uhdm.$T timeout 3000 python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out /tmp/r11u476_p_$T.csv --workroot /tmp/r11u476_sv$T --jobs 1 --paths-file /tmp/r11u476_row_p.txt --keep-golden --uvm-dir third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > /dev/null 2>&1
tail -1 /tmp/r11u476_p_$T.csv | cut -d, -f15-
G=/home/heyfey/.cache/slang-uhdm-goldens/0445655ee703/50a224b0134d47ab3870/golden.uhdm
f=/tmp/r11u476_sv$T/generated/uvm-examples/uvm_param_vif_config_db/slang.uhdm
echo "cmp=$($UHDM_CMP $G $f 2>&1 | wc -l)"
/tmp/r11u476_tools/addpa $f /tmp/r11u476_pa_$T.uhdm | tail -1
timeout 1200 $STRICTCMP --max ${MAX:-6} $G /tmp/r11u476_pa_$T.uhdm 2>&1 | tail -${TAILN:-14}
