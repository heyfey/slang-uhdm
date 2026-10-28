#!/bin/bash
# ds1.sh <casedir> <binary> <tag>: downstream verdict for one case via scripts/downstream_uhdm2rtlil.one
c=$(cd $1 && pwd); B=$2; t=$3
[ -x "$B" ] || { echo "no binary"; exit 2; }
source /tmp/v11u450_env.sh || exit 2
export SLANG_UHDM=$B
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
w=/tmp/v11u450_scr/ds/$t/$key; rm -rf $w; mkdir -p $w
cd /tmp/wt_v11u450 && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$key', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$w', 300); print('$key', r)"
