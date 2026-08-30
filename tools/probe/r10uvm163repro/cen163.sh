#!/usr/bin/env bash
# r10uvm163 — run ct163cen over the named row-modes of a verify_golden workdir,
# GOLDEN and OURS, and join the two cell sets.  MEASUREMENT ONLY.
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
#   usage: cen163.sh <workdir> <outdir> <name> [<name> ...]
# GUARDS:
#   * the golden path is read out of the row's OWN cmds.txt and turned into
#     .../golden.uhdm — this driver can never compare against the wrong golden;
#   * BOTH sides are existence-checked; a missing side prints SKIP-NOFILE and is
#     COUNTED, so a driver that reaches nothing cannot read as perfection;
#   * ct163cen itself refuses a database with zero class_typespec.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
CEN=${CT163CEN:?set CT163CEN to the built ct163cen}
[ -x "$CEN" ] || { echo "FATAL: no ct163cen at $CEN"; exit 3; }
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
        echo "SKIP-NOFILE $n/$mode g=${G:-none}"; miss=$((miss+1)); continue
      fi
      "$CEN" "$G" > "$OUT/$n.$mode.g.cen" 2>&1; grc=$?
      "$CEN" "$O" > "$OUT/$n.$mode.o.cen" 2>&1; orc=$?
      echo "CEN $n/$mode grc=$grc orc=$orc gcells=$(grep -c '^CELL' "$OUT/$n.$mode.g.cen"; true) ocells=$(grep -c '^CELL' "$OUT/$n.$mode.o.cen"; true)"
      done_=$((done_+1))
    done
  done
done
echo "-- measured=$done_ SKIP-NOFILE=$miss"
