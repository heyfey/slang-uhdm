#!/bin/bash
# allgrid.sh <out> <casedir>...: grid.sh over case dirs, 3 at a time, after a quiet wait (law /tmp/v11u431_law, pristine /tmp/v11u431_pris)
R=$(cd $(dirname $0) && pwd); O=$1; shift
bash $R/quiet3.sh
printf '%s\n' "$@" | xargs -P 3 -I{} bash $R/grid.sh /tmp/v11u431_law/slang-uhdm /tmp/v11u431_pris/slang-uhdm {} > $O.unsorted
sort $O.unsorted > $O; rm $O.unsorted; echo GRIDDONE
