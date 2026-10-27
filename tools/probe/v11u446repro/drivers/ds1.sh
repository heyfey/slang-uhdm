#!/bin/bash
# ds1.sh <binary> <tag> <casedir>...: downstream verdict per case (uhdm2rtlil plugin on
# Surelog's and slang-uhdm's database), workroot /tmp/v11u446_ds/<tag>
source /tmp/v11u446_scr/env.sh
export SLANG_UHDM=$1; t=$2; shift 2
[ -x "$SLANG_UHDM" ] || { echo "no binary"; exit 2; }
cd /tmp/wt_v11u446
for c in "$@"; do
  c=$(cd $c && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
  w=/tmp/v11u446_ds/$t; mkdir -p $w
  python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print('$key', '$t', ds.one('$key', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$w', 300))"
done
