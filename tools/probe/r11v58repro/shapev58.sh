#!/usr/bin/env bash
# r11v58 (VERIFIER) SHAPE LISTER driver — golden / pristine / patched / fixed
# element-size table for one arm, per listing section.
# usage: shapev58.sh <armname> <goldtag> [tags...]
set -u
H=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
A=${1:?arm}; GT=${2:?gold tag}; shift 2
D=$H/grid/$A
for v in uhdmallPackages uhdmtopPackages; do
  echo "== $A $v"
  printf '   %-5s ' GOLD
  python3 $H/../r11u58repro/sz58.py $D/gold.$GT.dump $v | tr '\n' '|'; echo
  for t in "$@"; do
    [ -f $D/ours.$t.dump ] || continue
    printf '   %-5s ' "$t"
    python3 $H/../r11u58repro/sz58.py $D/ours.$t.dump $v | tr '\n' '|'; echo
  done
done
