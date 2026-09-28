#!/bin/bash
# r11u188 (from r11u186repro): dscase.sh <binary, absolute> <case dir>... : the downstream gate's own one() on each case
# (dut.sv), GOLDEN_CACHE=${R188_DSGOLD:-/tmp/r11u188_dsgold}; prints "<case> <verdict row>".  Refuses a fenced path.
set -u; . "$(dirname "$0")/env.sh" || exit 2
BIN=$1; shift
export SLANG_UHDM=$BIN GOLDEN_CACHE=${R188_DSGOLD:-/tmp/r11u188_dsgold}
for c in "$@"; do
  C=$(readlink -f $c); r188_fenced "$C" && { echo "fenced path refused"; exit 3; }
  [ -f $C/dut.sv ] || continue
  W=/tmp/r11u188_dsw/$(basename $(dirname $C))_$(basename $C)_$(basename $BIN); rm -rf $W; mkdir -p $W
  (cd "$R188_REPO" && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print('$(basename $(dirname $C))/$(basename $C)', ds.one('$(basename $C)', '$C', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300))")
done
