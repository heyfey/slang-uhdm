#!/bin/bash
# ds.sh <bin> <tag> <case rel>... : downstream verdict via scripts/downstream_uhdm2rtlil.one
source /tmp/v11u462_env.sh
export SLANG_UHDM=$1; T=$2; shift 2
[ -x "$SLANG_UHDM" ] || exit 1
cd /tmp/wt_v11u462
for c in "$@"; do
  C=/tmp/wt_v11u462/tools/probe/v11u462repro/cases/$c
  WR=/tmp/v11u462_ds_$T/$(echo $c | tr / _); rm -rf $WR; mkdir -p $WR
  r=$(python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print(ds.one('$(basename $c)', '$C', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$WR', 300))" 2>&1 | tail -1)
  echo "$c $T $r"
done
