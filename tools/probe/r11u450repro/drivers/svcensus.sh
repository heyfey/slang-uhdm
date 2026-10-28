#!/bin/bash
/tmp/wt_r11u450/tools/probe/r11u450repro/drivers/quiet.sh
cd /tmp/wt_r11u450 && source /tmp/r11u450_env.sh && export SLANG_UHDM=/tmp/r11u450_bin/law12
rm -rf /tmp/r11u450_svcen /tmp/r11u450_svcen_tr; mkdir -p /tmp/r11u450_svcen_tr
date > /tmp/r11u450_svcen.start
R11U450_TRACE=/tmp/r11u450_svcen_tr timeout 3000 python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out /tmp/r11u450_svcen.csv --workroot /tmp/r11u450_svcen --jobs 3 --paths-file /tmp/r11u450_svcand.txt --uvm-dir /home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > /tmp/r11u450_svcen.log 2>&1
date > /tmp/r11u450_svcen.done
