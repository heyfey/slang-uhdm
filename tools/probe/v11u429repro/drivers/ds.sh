#!/bin/bash
# ds.sh <binary> <tag> <casedir>...: downstream verdict per case
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=$1; [ -x "$SLANG_UHDM" ] || exit 2; t=$2; shift 2
for c in "$@"; do c=$(cd $c && pwd); n=$(basename $(dirname $c))_$(basename $c)
 rm -rf /tmp/v11u429_ds_$t/$n
 (cd /tmp/wt_v11u429 && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u429_ds_$t', 300); print('$t', r['name'], r['verdict'], r['surelog_status'], r['slang_status'], r['surelog_gates'], r['slang_gates'], r['differs'])")
done
