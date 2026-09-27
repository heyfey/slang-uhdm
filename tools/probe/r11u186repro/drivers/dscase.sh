#!/bin/bash
# r11u186 (from r11u180repro): dscase.sh <binary> <case dir>... : the downstream gate's own one() on each case (dut.sv), fresh GOLDEN_CACHE;
# prints "<case> <verdict row>". Refuses a fenced path.
set -u; . /tmp/wt_r11u186/tools/probe/r11u186repro/drivers/env.sh || exit 2
BIN=$1; shift
export SLANG_UHDM=$BIN GOLDEN_CACHE=/tmp/r11u186_dsgold
for c in "$@"; do
  C=$(readlink -f $c)
  for f in $FENCED; do echo "$C" | grep -qw "$f" && { echo "fenced path refused"; exit 3; }; done
  W=/tmp/r11u186_dsw/$(basename $(dirname $C))_$(basename $C)_$(basename $BIN); rm -rf $W; mkdir -p $W
  (cd /tmp/wt_r11u186 && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print(ds.one('$(basename $C)', '$C', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300))")
done
