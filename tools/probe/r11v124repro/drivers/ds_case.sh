#!/bin/bash
# ds_case.sh <case dir> <tag> <binary>
c=$1; tag=$2; bin=$3; name=$(echo $c | sed 's#^/tmp/v11u124_cases/##; s#/#__#g')
cd /tmp/wt_v11u124
SLANG_UHDM=$bin GOLDEN_CACHE=/tmp/v11u124_dscache python3 -c "
import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds
r=ds.one('$name', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u124_ds_$tag', 300)
print('$name', '$tag', r['verdict'], r['differs'], r['slang_status'])" 2>&1 | tail -1
