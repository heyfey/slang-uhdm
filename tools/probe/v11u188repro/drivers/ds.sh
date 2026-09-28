#!/bin/bash
# v11u188: ds.sh <name> <binary> <case dir>...: the downstream gate's own one() on each case (dut.sv), goldens in
# GOLDEN_CACHE=${V188_DSGOLD:-/tmp/v11u188_dsgold}; prints "<cell> <name> <verdict dict>".  Refuses a fenced path.
. "$(dirname "$0")/env.sh" || exit 9
N=$1; B=$2; shift 2
export SLANG_UHDM=$B GOLDEN_CACHE=${V188_DSGOLD:-/tmp/v11u188_dsgold}
for c in "$@"; do
  C=$(readlink -f $c); v188_fenced "$C" && { echo "fenced path refused"; exit 9; }
  [ -f $C/dut.sv ] || continue
  W=/tmp/v11u188_dsw/$(basename $C)_$N; rm -rf $W; mkdir -p $W
  (cd "$V188_REPO" && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print('$(basename $C)', '$N', ds.one('$(basename $C)', '$C', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300))")
done
