#!/bin/bash
# v11u155_ds.sh <bin> <workroot> <casedir>...
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=$1 GOLDEN_CACHE=/tmp/v11u155_dsgc; W=$2; shift 2
args=(); for c in "$@"; do args+=("$(realpath $c)"); done; cd /tmp/wt_v11u155pris
for c in "${args[@]}"; do n=$(echo $c | sed 's#.*/v11u155repro/cases/##; s#/#_#g')
python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print('$n', ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300))"
done
