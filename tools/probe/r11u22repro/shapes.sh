#!/usr/bin/env bash
set -u
TAG=${1:-pris}
GRID=${GRID:-/tmp/r11u22_grid}
SH=${SH:-$(dirname "${BASH_SOURCE[0]}")/shape.py}
for a in $(ls -d $GRID/[a-z][0-9]* | xargs -n1 basename | sort -V); do
  echo "===== $a  ($(tr '\n' ' ' < $GRID/$a/rc.$TAG.txt 2>/dev/null))"
  if [ -f $GRID/$a/gold.$TAG.dump ] && [ -f $GRID/$a/ours.$TAG.dump ]; then
    python3 $SH $GRID/$a/gold.$TAG.dump $GRID/$a/ours.$TAG.dump
  else echo "  NODB"; fi
done
