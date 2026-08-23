#!/bin/bash
# r10uvm111 predall.sh — a-priori mover prediction over EVERY pristine database
# in a verify_golden workdir.  Prints "<mode>/<test> <cells>" for every DB with
# a nonzero cell count, and a TOTAL line.  Measurement only.
set -u
WD=${1:?workdir}
P=${P:-/tmp/r10uvm111_scratch/pred111}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
find "$WD" -name slang.uhdm -print0 | xargs -0 -P 4 -I{} bash -c '
  f="{}"; n=$("'"$P"'" "$f" 2>/dev/null | sed -n "s/^CELLS //p"); n=${n:-ERR}
  [ "$n" != "0" ] && echo "$n $f"
' 
echo "SCANNED $(find "$WD" -name slang.uhdm | wc -l)"
