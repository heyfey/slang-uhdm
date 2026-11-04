#!/bin/bash
# ds.sh <bin> <tag> <casedir>...: downstream verdict per case (scripts/downstream_uhdm2rtlil.py one())
source $(dirname "$0")/env.sh || exit 1
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
export SLANG_UHDM=$B GOLDEN_CACHE=/tmp/v11u483_dsgc
for c in "$@"; do
  c=$(realpath "$c")
  n=$(echo "${c#*/cases/}" | tr / _)
  rm -rf /tmp/v11u483_ds_$T/$n
  (cd /home/heyfey/git-repos/slang-uhdm && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u483_ds_$T', 300); print('${c#*/cases/}', r['verdict'], r['differs'], r['detail'][:80])")
done
