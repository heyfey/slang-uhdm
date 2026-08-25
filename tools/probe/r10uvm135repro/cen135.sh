#!/usr/bin/env bash
# r10uvm135repro/cen135.sh — THE DIRECTION CENSUS over named rows.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
#   cen135.sh <pristine sweep wd> <patched sweep wd> <ct135cen> <score135.py> <name> [...]
#
# For every named test x mode it censuses GOLDEN (read out of the workdir's own
# cmds.txt, so the wrong golden cannot be compared), the PRISTINE database and
# the PATCHED one, and scores every implicit-net cell and every associative-
# index-name cell TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG.
# LHS is ALWAYS golden.
set -u
WP=${1:?pristine wd}; WQ=${2:?patched wd}; CEN=${3:?ct135cen}; SC=${4:?score135.py}
shift 4
T=$(mktemp -d /tmp/r10uvm135_cen.XXXXXX)
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WP/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      t=$(basename "$d")
      C="$d/cmds.txt"; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G="$G/golden.uhdm"
      P="$d/slang.uhdm"; Q="$WQ/$mode/$t/slang.uhdm"
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$P" ] || [ ! -f "$Q" ]; then
        echo "######## $n/$mode  SKIP-NOFILE"; continue
      fi
      "$CEN" "$G" G > "$T/g.txt"; "$CEN" "$P" O > "$T/a.txt"; "$CEN" "$Q" O > "$T/b.txt"
      echo "######## $n/$mode"
      python3 "$SC" "$T/g.txt" "$T/a.txt" "$T/b.txt"
    done
  done
done
rm -rf "$T"
