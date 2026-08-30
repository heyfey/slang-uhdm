#!/usr/bin/env bash
# r10uvm164repro/census164.sh -- the CORPUS census.  MEASUREMENT ONLY;
# `uhdm-cmp` is the sole judge.  LHS is ALWAYS golden, RHS is ALWAYS ours.
#
#   census164.sh <workdir> <ct164cen> <outdir> <mode/row> [<mode/row> ...]
#
# For each named row it censuses BOTH sides -- golden (read out of the row's own
# cmds.txt, so the census cannot silently compare against the wrong golden, and
# the cache DIRECTORY is turned into .../golden.uhdm) and ours -- and writes
# <outdir>/<mode>.<row>.{g,o}.txt.  A row whose golden or database is missing
# prints SKIP-NOFILE and is COUNTED: a driver that reaches nothing must never
# read as a complete census.
set -u
WD=${1:?workdir}; CEN=${2:?ct164cen}; OUT=${3:?outdir}; shift 3
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no census tool $CEN"; exit 3; }
mkdir -p "$OUT" || exit 1
done_n=0; miss=0
for r in "$@"; do
  mode=${r%%/*}; row=${r#*/}
  d="$WD/$mode/$row"
  O="$d/slang.uhdm"; C="$d/cmds.txt"; G=""
  [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G="$G/golden.uhdm"
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    echo "SKIP-NOFILE $r (g=${G:-none})"; miss=$((miss+1)); continue
  fi
  "$CEN" "$G" "G.$mode" > "$OUT/$mode.$row.g.txt" 2>>"$OUT/cen.err"; grc=$?
  "$CEN" "$O" "O.$mode" > "$OUT/$mode.$row.o.txt" 2>>"$OUT/cen.err"; orc=$?
  echo "OK $r golden-rc=$grc ours-rc=$orc g=$(grep -c '^CAS' "$OUT/$mode.$row.g.txt") o=$(grep -c '^CAS' "$OUT/$mode.$row.o.txt")"
  done_n=$((done_n+1))
done
echo "-- censused=$done_n  SKIP-NOFILE=$miss"
