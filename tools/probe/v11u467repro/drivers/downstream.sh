#!/bin/bash
# downstream.sh <bin> <tag> <casedir>...: the downstream verdict of each case (scripts/downstream_uhdm2rtlil.py one()).
source /tmp/v11u467_env.sh || exit 1
B=$1; T=$2; shift 2; [ -x "$B" ] || { echo "no binary $B"; exit 1; }
export SLANG_UHDM=$B
for c in "$@"; do
  c=$(realpath "$c"); n=$(basename "$c"); W=/tmp/v11u467_ds_$T; mkdir -p $W
  (cd /home/heyfey/git-repos/slang-uhdm && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300); print('${c#*/cases/}', r)" </dev/null 2>&1 | tail -1)
done
