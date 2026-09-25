#!/bin/bash
# v11u160_ds1.sh <casedir> <binary> <workroot>
source $(dirname $0)/env.sh
export SLANG_UHDM=$2; export GOLDEN_CACHE=/tmp/v11u160_gc
cd /tmp/wt_v11u160
python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$(basename $1)', '$1', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$3', 300); print(r)"
