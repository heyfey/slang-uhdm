#!/bin/bash
# ds.sh <casedir> <binary> <tag> : downstream verdict for one case
c=$1; B=$2; t=$3
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=$B GOLDEN_CACHE=${GC:-/tmp/v11u412_dsgc}
rel=${c#/tmp/v11u412_cases/}; nm=$(echo $rel | tr / _)
w=/tmp/v11u412_ds/$t; mkdir -p $w
cd /tmp/wt_v11u412 && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$nm', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$w', 300); print('$rel $t', r)"
