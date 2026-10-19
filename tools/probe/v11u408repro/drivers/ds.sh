#!/bin/bash
# ds.sh <binary> <tag> <case...>: downstream verdict per case
B=$1; T=$2; shift 2
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$B
cd /tmp/wt_v11u408
for c in "$@"; do
  n=$(echo $c | tr / _)
  python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print('$c $T', ds.one('$n', '/tmp/v11u408_cases/$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u408_dsw_$T', 300))"
done
