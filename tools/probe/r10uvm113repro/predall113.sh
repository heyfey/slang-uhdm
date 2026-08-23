#!/bin/bash
# r10uvm113 predall113.sh — a-priori mover prediction over EVERY pristine
# database in a verify_golden workdir.  Prints "<cells> <path>" for every DB
# with a nonzero cell count, then MAYBE rows, then the scan total.
# MEASUREMENT ONLY.  Derived from r10uvm111repro/predall.sh.
set -u
WD=${1:?workdir}
P=${P:-/tmp/r10uvm113_scratch/pred113}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
find "$WD" -name slang.uhdm -print0 | xargs -0 -P 4 -I{} bash -c '
  f="{}"; o=$("'"$P"'" "$f" 2>/dev/null)
  n=$(printf "%s" "$o" | sed -n "s/^CELLS //p"); n=${n:-ERR}
  m=$(printf "%s" "$o" | sed -n "s/^MAYBE //p"); m=${m:-0}
  [ "$n" != "0" ] && echo "PREDICT $n $f"
  [ "$m" != "0" ] && echo "MAYBE   $m $f"
  true
'
echo "SCANNED $(find "$WD" -name slang.uhdm | wc -l)"
