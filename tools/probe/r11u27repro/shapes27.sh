#!/usr/bin/env bash
# r11u27 shape table: golden vs a tagged run, the FIRST cont_assign cell per arm
set -u
GRID=${GRID:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/grid}
TAG=${1:-pris}
for d in $(ls -d $GRID/* | sort -V); do
  a=$(basename $d)
  [ -f $d/gold.$TAG.dump ] || { echo "$a NOGOLD"; continue; }
  g=$(python3 $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/carhs27.py $d/gold.$TAG.dump 2>/dev/null | head -1 | sed 's/  */ /g')
  o=$(python3 $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/carhs27.py $d/ours.$TAG.dump 2>/dev/null | head -1 | sed 's/  */ /g')
  echo "$a"
  echo "   G $g"
  echo "   O $o"
done
