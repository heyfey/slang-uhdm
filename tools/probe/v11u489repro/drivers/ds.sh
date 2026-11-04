#!/bin/bash
# ds.sh <bin> <tag> <out> <casedir>...: downstream verdict per case
source /tmp/v11u489_drv/env.sh || exit 1
export SLANG_UHDM=$1; T=$2; O=$3; shift 3
[ -x "$SLANG_UHDM" ] || exit 1
: > $O
for c in "$@"; do
  c=$(realpath $c); n=${c#/tmp/wt_v11u489/tools/probe/v11u489repro/cases/}; W=/tmp/v11u489_ds/$T/$n; rm -rf $W; mkdir -p $W
  (cd /tmp/wt_v11u489 && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('${n//\//_}', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300); print('$n', r)") >> $O 2>/dev/null
done
