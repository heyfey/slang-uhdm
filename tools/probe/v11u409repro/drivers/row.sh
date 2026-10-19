#!/bin/bash
# v11u409_row.sh <binary> <pathsfile> <outdir> [ENV=VAL...]
B=$1; P=$2; O=$3; shift 3
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump SLANG_UHDM=$B
rm -rf $O; mkdir -p $O; cd /home/heyfey/git-repos/slang-uhdm
env "$@" python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out $O/m.csv --workroot $O/work --jobs 3 --paths-file $P --keep-golden --uvm-dir third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > $O/log 2>&1
