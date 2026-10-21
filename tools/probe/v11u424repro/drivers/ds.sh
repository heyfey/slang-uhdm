#!/bin/bash
# ds.sh <binary> <tag> <casedir>: downstream verdict line
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=$1; t=$2; c=$3
[ -x "$SLANG_UHDM" ] || exit 1
key=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
cd /tmp/wt_v11u424 && python3 -c "
import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds
r=ds.one('$key', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u424_scr/ds_$t', 300)
print('$key', '$t', r['verdict'], r['differs'], r['surelog_gates'], r['slang_gates'])"
