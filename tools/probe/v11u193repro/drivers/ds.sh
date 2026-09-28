#!/bin/bash
# usage: ds.sh <bin name> <case dir...> : downstream verdict per case with $V193_BIN/<bin>.bin
. "$(dirname "$0")/env.sh" || exit 3
b=$1; shift
export SLANG_UHDM=$V193_BIN/$b.bin
for c in "$@"; do D=$(cd $c && pwd); v193_fenced "$D" && { echo "fenced refused"; continue; }
  W=/tmp/v11u193_ds/$b/$(basename $D); rm -rf $W; mkdir -p $W
  (cd $REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$(basename $D)', '$D', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300); print('$b', r)")
done
