#!/bin/bash
# ds.sh <binary> <tag> <casedir...> : downstream verdict per case
b=$1; t=$2; shift 2
CS=(); for c in "$@"; do CS+=("$(realpath $c)"); done
source /tmp/v11u178_env.sh
export SLANG_UHDM=$b GOLDEN_CACHE=/tmp/v11u178_dsgc
cd /tmp/wt_v11u178
for c in "${CS[@]}"; do
  if echo "$c" | grep -qE "$FENCED_RE"; then echo refuse; continue; fi
  n=$(echo $c | sed 's#/tmp/v11u178_cases/##; s#/#__#g')
  rm -rf /tmp/v11u178_dsw/$t/$n
  python3 -c "
import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds
r=ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u178_dsw/$t', 300)
print('$t', r['name'], r['verdict'], r['surelog_status'], r['slang_status'], r['surelog_gates'], r['slang_gates'], r['differs'], r['detail'][:80])"
done
