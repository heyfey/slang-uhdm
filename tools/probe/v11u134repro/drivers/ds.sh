#!/bin/bash
# ds.sh <bin tag P|L> <case...>
source /tmp/v11u134_env.sh
export GOLDEN_CACHE=/tmp/v11u134_gc
GRID=$(cd $(dirname $0)/../grid && pwd)
t=$1; shift
[ $t = P ] && export SLANG_UHDM=/tmp/v11u134_bin/pris || export SLANG_UHDM=/tmp/v11u134_bin/law
cd /tmp/wt_v11u134
for c in "$@"; do
python3 -c "
import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds
r=ds.one('$c', '$GRID/$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u134_scr/dsw$t', 300)
print('$t', r['name'], r['verdict'], r['surelog_status'], r['slang_status'], r['differs'], r['detail'][:80])"
done
