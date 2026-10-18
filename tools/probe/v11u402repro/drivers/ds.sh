#!/bin/bash
# ds.sh <casesroot> <binary> <tag> : downstream verdict per class-free case
. /tmp/v11u402_env.sh
export SLANG_UHDM=$2
cd /tmp/wt_v11u402
for c in $(cd $1 && find . -name dut.sv | sort); do rel=${c#./}; rel=${rel%/dut.sv}; d=$1/$rel
  grep -q '\bclass\b\|program\|covergroup\|package' $d/dut.sv && continue
  wr=/tmp/v11u402_ds_$3/$(echo $rel|tr / _); rm -rf $wr; mkdir -p $wr
  v=$(timeout 600 python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$(basename $rel)', '$d', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$wr', 300); print(r['verdict'], r['differs'], r['slang_status'])" 2>&1 | tail -1)
  echo "$rel | $v"
done
