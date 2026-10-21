#!/bin/bash
# dsgrid.sh <law binary> <pristine binary> <casedir>...: downstream verdict (uhdm2rtlil
# Yosys plugin, Surelog lane vs slang lane) per case for both binaries.
source /tmp/wt_v11u428/tools/probe/v11u428repro/drivers/env.sh
export GOLDEN_CACHE=/tmp/v11u428_dscache
L=$1; P=$2; shift 2
[ -x "$L" ] && [ -x "$P" ] || exit 2
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || continue
  c=$(cd $c && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
  top=""; [ -f $c/TOP ] && top="-top $(cat $c/TOP)"
  for b in P L; do
    bin=$P; [ $b = L ] && bin=$L
    v=$(cd /tmp/wt_v11u428 && SLANG_UHDM=$bin python3 -c "
import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds
r=ds.one('$key', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv']+'$top'.split(), '/tmp/v11u428_ds/$b', 300)
print(r['verdict'], r.get('differs',''))" 2>/dev/null | tail -1)
    eval "v$b=\"\$v\""
  done
  echo "$key | pristine $vP | law $vL"
done
