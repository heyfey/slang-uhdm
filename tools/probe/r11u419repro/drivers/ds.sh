#!/bin/bash
# r11u419 ds.sh <binary> <workroot> <casedir>... : downstream verdict per case (uhdm2rtlil harness one())
B=$1; W=$2; shift 2; R=/tmp/wt_r11u419
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$B
for c in "$@"; do c=$(readlink -f $c); n=$(basename $(dirname $c))_$(basename $c)
 (cd $R && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300); print(r['name'], r['verdict'], r['surelog_gates'], r['slang_gates'], r['differs'], r['detail'][:80])")
done
