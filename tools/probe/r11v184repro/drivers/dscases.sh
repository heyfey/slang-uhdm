#!/bin/bash
# dscases.sh <binary> <tag> <case-root>...: downstream verdict of every case (scripts/downstream_uhdm2rtlil.py's one())
D=$(cd "$(dirname "$0")" && pwd); source $D/env.sh || exit 9
export SLANG_UHDM=$1; tag=$2; shift 2
cd $V184_REPO
for root in "$@"; do for c in $(find $root -name dut.sv -printf '%h\n' | sort); do
  echo "$c" | grep -qP "$FENCED_RE" && { echo "FENCE refuse $c"; continue; }
  c=$(realpath $c); n=$(echo $c | sed 's#.*/cases/##; s#/#_#g')
  python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u184_ds_$tag', 300); print('$n', r.get('verdict'), r.get('differs',''), r.get('detail',''))" 2>&1 | tail -1
done; done
