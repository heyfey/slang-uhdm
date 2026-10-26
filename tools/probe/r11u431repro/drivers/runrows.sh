#!/bin/bash
# runrows.sh <binary> <list> <out.csv> <workroot>: targeted runner call
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump SLANG_UHDM=$1
for v in SURELOG UHDM_CMP UHDM_DUMP SLANG_UHDM; do [ -x "${!v}" ] || { echo "missing $v"; exit 2; }; done
cd /home/heyfey/git-repos/slang-uhdm
python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out $3 --workroot $4 --jobs 3 --paths-file $2 --keep-golden --uvm-dir third_party/Surelog/third_party/UVM/1800.2-2017-1.0
