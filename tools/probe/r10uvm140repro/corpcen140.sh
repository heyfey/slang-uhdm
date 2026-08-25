#!/usr/bin/env bash
# r10uvm140 — run ct140cen over the NAMED databases of a verify_golden workdir
# (golden path read from the workdir's own cmds.txt, cache DIR -> golden.uhdm).
# LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY.
#   usage: CEN=<ct140cen> corpcen140.sh <workdir> <name> [<name> ...]
set -u
WD=${1:?workdir}; shift
CEN=${CEN:?set CEN}
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm; C=$d/cmds.txt; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        echo -e "SKIP-NOFILE\t$n/$mode"; continue
      fi
      "$CEN" "$G" "$O" "$n/$mode"
    done
  done
done
