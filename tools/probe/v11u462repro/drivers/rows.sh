#!/bin/bash
# rows.sh <bin> <tag>: the targeted sv-tests rows through the runner, goldens kept
source /tmp/v11u462_env.sh
export SLANG_UHDM=$1; T=$2; [ -x "$SLANG_UHDM" ] || exit 1
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out /tmp/v11u462_rows_$T.csv --workroot /tmp/v11u462_rows_$T --jobs 3 --paths-file /tmp/v11u462_rows.lst --keep-golden --uvm-dir third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > /tmp/v11u462_rows_$T.log 2>&1
echo rc=$?
