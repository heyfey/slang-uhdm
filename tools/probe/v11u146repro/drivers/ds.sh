#!/bin/bash
# (v11u146) the setup file exports the tool paths of the brief and $FENCED; see ../README.md
# v11u146_ds.sh <binary> <tag> <case...>  -> downstream verdict per case
. /tmp/v11u146_env.sh
b=$1; t=$2; shift 2
export SLANG_UHDM=$b GOLDEN_CACHE=/tmp/v11u146_gc
cd /tmp/wt_v11u146pris
for c in "$@"; do
  d=/tmp/v11u146_cases/$c; w=/tmp/v11u146_ds_$t/$(echo $c | tr / _); rm -rf $w; mkdir -p $w
  python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$(basename $c)', '$d', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$w', 300); print('$c', r)" 2>&1 | tail -1
done
