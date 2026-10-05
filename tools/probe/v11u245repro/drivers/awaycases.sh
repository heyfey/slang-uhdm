#!/bin/bash
# v11u245: away census over every case-view under $S/g: golden vs <tagP> vs <tagL> (default pristine law).
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); P=${1:-pristine}; L=${2:-law}; wd=$S/away; mkdir -p $wd
for w in $(find $S/g -mindepth 2 -maxdepth 2 -type d | sort); do
  for n in $FENCED; do echo "$w" | grep -qw "$n" && continue 2; done
  g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1); [ -s "$g" ] && [ -s $w/$P.uhdm ] && [ -s $w/$L.uhdm ] || continue
  echo "${w#$S/g/} $(python3 $H/drivers/away.py $g $w/$P.uhdm $w/$L.uhdm $wd ${VERB:+v})"
done
