#!/bin/bash
# v11u417 ds.sh <bin> <tag> <out> <casedir...> : downstream verdict per case
B=$1; T=$2; OUT=$3; shift 3
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$B
cd /tmp/wt_v11u417
for c in "$@"; do n=$(echo $c | tr / _)
python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$(readlink -f /tmp/wt_v11u417/tools/probe/v11u417repro/cases/$c)', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u417_ds_$T', 300); print('$c', r['verdict'], r['surelog_status'], r['slang_status'], r['differs'])" >> $OUT 2>/tmp/v11u417_scr/ds_err_$T.log
done
