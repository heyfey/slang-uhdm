#!/bin/bash
# ds.sh <bin> <tag> <casedir>... : downstream verdict per case
source /tmp/v11u477_env.sh
export SLANG_UHDM=$1; T=$2; shift 2
[ -x "$SLANG_UHDM" ] || { echo nobin; exit 1; }
ARGS=(); for c in "$@"; do ARGS+=("$(realpath $c)"); done; set -- "${ARGS[@]}"; cd /tmp/wt_v11u477 || exit 1
for c in "$@"; do
  c=$(realpath $c); n=$(basename $c)
  W=/tmp/v11u477_ds/$T/$(basename $(dirname $c))_$n; rm -rf $W; mkdir -p $W
  r=$(python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print(ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300))" 2>&1 | tail -1)
  echo "$(basename $(dirname $c))/$n $T $r"
done
