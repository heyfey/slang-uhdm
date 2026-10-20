#!/bin/bash
# ds.sh <binary> <tag> <case dirs...>: downstream verdict per case (uhdm2rtlil lanes via ds.one)
B=$1; t=$2; shift 2
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SLANG_UHDM=$B
export GOLDEN_CACHE=/tmp/v11u416_scr/dsgc
for c in "$@"; do c=$(cd $c && pwd); n=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
  w=/tmp/v11u416_scr/ds_$t; mkdir -p $w
  r=$(cd /tmp/wt_v11u416 && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print(ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$w', 300))" 2>&1 | tail -1)
  echo "$n $t $r"
done
