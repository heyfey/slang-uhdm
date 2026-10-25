#!/bin/bash
# dsgrid3.sh <verified> <law> <pristine> <casedir>...: downstream verdict per case for the three binaries
source /tmp/v11u430_scratch/env.sh
export GOLDEN_CACHE=/tmp/v11u430_dscache
V=$1; L=$2; P=$3; shift 3
[ -x "$V" ] && [ -x "$L" ] && [ -x "$P" ] || exit 2
for c in "$@"; do
  [ -d $c ] && [ -f $c/dut.sv ] || continue
  c=$(cd $c && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
  top=""; [ -f $c/TOP ] && top="-top $(cat $c/TOP)"
  out="$key"
  for b in P L V; do
    bin=$P; [ $b = L ] && bin=$L; [ $b = V ] && bin=$V
    v=$(cd /tmp/wt_v11u430 && SLANG_UHDM=$bin python3 -c "
import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds
r=ds.one('$key', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv']+'$top'.split(), '/tmp/v11u430_ds/$b', 300)
print(r['verdict'], r.get('differs',''))" 2>/dev/null | tail -1)
    out="$out | $b $v"
  done
  echo "$out"
done
