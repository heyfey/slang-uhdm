#!/usr/bin/env bash
# r10uvm192repro/scoregrid192.sh — score one grid arm's censuses with
# `score192.py`.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
# `grid192.sh` writes `cen.{g,a,b}.{def,elab}.txt` (g = the REAL Surelog
# golden, a = pristine, b = patched).  `score192.py` wants `<row>.g`/`<row>.o`
# pairs in one directory, one row per VIEW so the two views are never merged
# into one multiset.  This lays them out that way — once for the pristine
# binary and once for the patched one — and prints both verdicts.
#
#   usage: scoregrid192.sh <grid workdir> <arm name>
set -u
W=${1:?grid workdir}
NM=${2:?arm name}
HERE=$(cd "$(dirname "$0")" && pwd)
for side in a b; do
  D="$W/score.$side"
  rm -rf "$D"; mkdir -p "$D" || exit 3
  for v in def elab; do
    [ -f "$W/cen.g.$v.txt" ] || { echo "MISSING $W/cen.g.$v.txt"; continue; }
    [ -f "$W/cen.$side.$v.txt" ] || { echo "MISSING $W/cen.$side.$v.txt"; continue; }
    cp "$W/cen.g.$v.txt"    "$D/$v.$NM.g"
    cp "$W/cen.$side.$v.txt" "$D/$v.$NM.o"
  done
  echo "==== $NM  $([ $side = a ] && echo PRISTINE || echo PATCHED)"
  python3 "$HERE/score192.py" "$D"
done
