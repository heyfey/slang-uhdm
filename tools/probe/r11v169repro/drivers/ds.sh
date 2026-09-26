#!/bin/bash
# ds.sh <tag> <bin> <case...>: downstream verdict per case
source $(dirname $0)/env.sh
t=$1; b=$2; shift 2
export SLANG_UHDM=$b GOLDEN_CACHE=/tmp/v11u169_gcache
cd /tmp/wt_v11u169pris
for c in "$@"; do
  n=$(echo $c | tr / _)
  python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '/tmp/v11u169_cases/$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u169_dsw/$t', 300); print('$t', '$c', r['verdict'], r['surelog_status'], r['slang_status'], r['differs'], r['detail'])"
done
