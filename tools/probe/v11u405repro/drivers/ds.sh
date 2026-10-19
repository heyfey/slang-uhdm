#!/bin/bash
# ds.sh <binary> <workroot> : downstream verdict (scripts/downstream_uhdm2rtlil.py one()) on every
# class-free case dir of v11u405repro; one line per case.
H=$(cd $(dirname $0)/.. && pwd); B=$1; W=$2; mkdir -p $W
export SLANG_UHDM=$B SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
cd /tmp/wt_v11u405
for d in $(find $H/cases -name dut.sv | sort | grep -E "${FILTER:-.}"); do c=$(dirname $d)
  grep -q '^ *class ' $d && continue
  k=$(basename $(dirname $c))/$(basename $c)
  r=$(python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print(ds.one('$(echo $k|tr / _)', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300))" 2>&1 | tail -1)
  echo "$k $r"
done
