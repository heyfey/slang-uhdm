#!/bin/bash
# ds.sh <tag> <bin> <casedir>...: downstream verdict per case (GOLDEN_CACHE private), workroot /tmp/v11u460_ds/<tag>
source /tmp/wt_v11u460/tools/probe/v11u460repro/drivers/env.sh || exit 1
T=$1; export SLANG_UHDM=$2; shift 2; [ -x "$SLANG_UHDM" ] || exit 1
export GOLDEN_CACHE=/tmp/v11u460_dscache; mkdir -p $GOLDEN_CACHE /tmp/v11u460_ds/$T
A=(); for c in "$@"; do A+=("$(realpath $c)"); done
cd /tmp/wt_v11u460
for c in "${A[@]}"; do n=$(echo ${c#*/cases/} | tr / _)
python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u460_ds/$T', 300); print(r['name'], r['verdict'], r['differs'], r['detail'][:80])"
done
