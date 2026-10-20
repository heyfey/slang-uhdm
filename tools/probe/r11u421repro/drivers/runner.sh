#!/bin/bash
# runner.sh <binary> <pathsfile> <workroot> <out.csv>
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump SLANG_UHDM=$1
[ -x "$SURELOG" ] && [ -x "$UHDM_CMP" ] && [ -x "$SLANG_UHDM" ] || exit 9
/tmp/r11u421_bin/quiet.sh || exit 8
cd /home/heyfey/git-repos/slang-uhdm && python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out $4 --workroot $3 --jobs 2 --paths-file $2 --keep-golden --uvm-dir /home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0
