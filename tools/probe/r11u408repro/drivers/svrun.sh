#!/bin/bash
# svrun.sh <binary> <paths-file> <workroot> <out.csv> [jobs]
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=$1
cd /home/heyfey/git-repos/slang-uhdm && python3 /tmp/wt_r11u408/scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out $4 --workroot $3 --jobs ${5:-2} --paths-file $2 --keep-golden --uvm-dir /home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0
