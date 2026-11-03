#!/bin/bash
source /tmp/r11u473_env.sh
export SLANG_UHDM=/tmp/r11u473_bin/law6 SLANG_UHDM_REPO=/home/heyfey/git-repos/slang-uhdm R11U473_TRACE=/tmp/r11u473_svc/trace
[ -x "$SLANG_UHDM" ] || exit 1
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out /tmp/r11u473_svc/matrix.csv --workroot /tmp/r11u473_svc/work --jobs 3 --paths-file /tmp/r11u473_svc/sv_cand.txt --uvm-dir /home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > /tmp/r11u473_svc/run.log 2>&1
echo "rc=$?" >> /tmp/r11u473_svc/run.log
