#!/usr/bin/env bash
# r11v54 (verifier) — THREE-WAY SHAPE TABLE for a grid arm: golden / pristine /
# patched, one line per param_assign, Compare-visible fields only.  Reuses
# r11u54repro/shape54.py (the SHAPE LISTER) and r11u54repro/run54.sh (the
# runner); this script only lines the three readings up so a cell that MOVED is
# read next to the cell golden actually has.
#
#   usage: vshape54.sh <armdir> [section-substring]
# The arm must already have been run with tags `pris` and `pat`.
set -u
D=${1:?armdir}; S=${2:-uhdmtopPackages}
SH=${SH:-/home/heyfey/git-repos/slang-uhdm/tools/probe/r11u54repro/shape54.py}
for T in gold.pat ours.pris ours.pat; do
  [ -f "$D/$T.dump" ] || { echo "MISSING $D/$T.dump"; exit 3; }
  echo "=== $(basename $D) $T [$S]"
  python3 "$SH" "$D/$T.dump" "$S"
done
