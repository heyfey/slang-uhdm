#!/bin/bash
# r10uvm149 — run ct149cen over a NAMED set of rows in a verify_golden workdir,
# GOLDEN and OURS, both modes.  MEASUREMENT ONLY.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   usage: corpcen149.sh <workdir> <outdir> <ct149cen> <name> [<name> ...]
#
# GUARDS: uhdm-cmp/censuses exit 0 on a MISSING file, so BOTH sides are
# existence-checked and a missing side prints SKIP-NOFILE and is COUNTED; the
# golden path is read out of the row's OWN cmds.txt (so the census cannot
# silently read the wrong golden) and the cache DIRECTORY is turned into
# .../golden.uhdm; scratch is keyed on the RELATIVE row path.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; CEN=${3:?ct149cen}
shift 3
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no census binary $CEN"; exit 3; }
mkdir -p "$OUT" || exit 1
miss=0; done_=0
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm; C=$d/cmds.txt; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        echo "SKIP-NOFILE $n $mode g=${G:-none}"; miss=$((miss+1)); continue
      fi
      "$CEN" "$G" "GOLD.$n.$mode" > "$OUT/g.$n.$mode.txt" 2>"$OUT/g.$n.$mode.err"
      echo "  rc_gold=$? $n $mode"
      "$CEN" "$O" "OURS.$n.$mode" > "$OUT/o.$n.$mode.txt" 2>"$OUT/o.$n.$mode.err"
      echo "  rc_ours=$? $n $mode"
      done_=$((done_+1))
    done
  done
done
echo "-- censused=$done_ SKIP-NOFILE=$miss"
