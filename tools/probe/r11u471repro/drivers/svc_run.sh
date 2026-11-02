#!/bin/bash
source /tmp/r11u471_env.sh
export SLANG_UHDM=/tmp/r11u471_bin/law13 SLANG_UHDM_REPO=/home/heyfey/git-repos/slang-uhdm R11U471_TRACE=/tmp/r11u471_svc/trace
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out /tmp/r11u471_svc/matrix.csv --workroot /tmp/r11u471_svc/work --jobs 3 --paths-file /tmp/r11u471_s/sv_cand.txt --uvm-dir /home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > /tmp/r11u471_svc/run.log 2>&1
echo "rc=$?" >> /tmp/r11u471_svc/run.log
