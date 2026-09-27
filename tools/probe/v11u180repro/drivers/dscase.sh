#!/bin/bash
# dscase.sh <binary> <case dir>... : the downstream gate's own one() per case, own GOLDEN_CACHE
set -u; . /tmp/v11u180_scr/env.sh || exit 2
BIN=$1; shift
export SLANG_UHDM=$BIN GOLDEN_CACHE=/tmp/v11u180_dsgold
for c in "$@"; do
  C=$(readlink -f $c)
  for f in $FENCED; do echo "$C" | grep -qw "$f" && { echo "fenced path refused"; exit 3; }; done
  W=/tmp/v11u180_dsw/$(basename $(dirname $C))_$(basename $C)_$(basename $BIN); rm -rf $W; mkdir -p $W
  echo "$(basename $(dirname $C))/$(basename $C) $(basename $BIN) $(cd /tmp/wt_v11u180 && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print(ds.one('$(basename $C)', '$C', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300))" 2>&1 | tail -1)"
done
