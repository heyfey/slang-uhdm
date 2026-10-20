#!/bin/bash
# ds.sh <binary> <tag> <casedir>...: downstream verdict (scripts/downstream_uhdm2rtlil.py one()) per case dir, the case copied to /tmp/v11u414_ds/<tag>/<case> first
B=$1; t=$2; shift 2
export SLANG_UHDM=$B UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
for c in "$@"; do
  n=$(basename $(dirname $c))_$(basename $c); d=/tmp/v11u414_ds/$t/$n; rm -rf $d; mkdir -p $d/src; cp $c/dut.sv $d/src/
  r=$(cd /tmp/wt_v11u414 && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print(ds.one('$n', '$d/src', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$d/work', 300))" 2>&1 | tail -1)
  echo "$n $t $r"
done
