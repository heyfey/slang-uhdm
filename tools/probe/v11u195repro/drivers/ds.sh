#!/bin/bash
# ds.sh <bin label> <case dir>...: downstream verdict of each case with $VB/<bin>.bin; fence fail-closed
. "$(dirname "$(realpath "$0")")"/env.sh || exit 3
b=$1; shift
export SLANG_UHDM=$VB/$b.bin
for c in "$@"; do for f in $FENCED; do grep -qw "$f" <<< "$c" && { echo "fenced refused"; exit 3; }; done
  n=$(echo $c | sed 's#.*/cases/##; s#/#_#g'); w=/tmp/v11u195_ds/$b; mkdir -p $w; rm -rf $w/$n
  ( cd "$REPO" && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$w', 300); print('$b', r)" ) 2>&1 | tail -1
done
