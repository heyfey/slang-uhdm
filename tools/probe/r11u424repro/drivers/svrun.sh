#!/bin/bash
# svrun.sh <binary> <paths-file> <workroot> <out.csv>: the sv-tests runner on listed rows (kept goldens)
source /tmp/r11u424_scratch/env.sh
export SLANG_UHDM=$1
[ -x "$SLANG_UHDM" ] && [ -x "$SURELOG" ] || { echo "bad tool"; exit 2; }
rm -rf $3 $4
cd /tmp/wt_r11u424 && timeout 3600 python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out $4 --workroot $3 --jobs 3 --paths-file $2 --keep-golden --uvm-dir /home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0 2>&1 | tail -2
cut -d, -f2,8,12,16,17,18 $4
