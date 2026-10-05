#!/bin/bash
# (r11u250) dbmovers.sh <law sweep wd> <pristine sweep wd>: byte movers among the probe databases (probe/*.uhdm) and the
# downstream slang lanes (downstream/<test>/slang/*.uhdm) of two gate sweeps. Path lists are built first and filtered
# by $FENCED (word boundary, fail closed) before any file is opened; the corpus databases are byteverify's.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "dbmovers.sh: FENCED not 4 names" >&2; exit 2; }
fre=$(echo $FENCED | tr ' ' '|'); L=$1; P=$2
for part in probe downstream; do
  (cd $L && find $part -name '*.uhdm' -path '*' | sort) | grep -vwE "$fre" > /tmp/r11u250_dbm_$part.lst
  [ "$part" = downstream ] && grep '/slang/' /tmp/r11u250_dbm_$part.lst > /tmp/r11u250_dbm_$part.lst2 && mv /tmp/r11u250_dbm_$part.lst2 /tmp/r11u250_dbm_$part.lst
  n=0; m=0; miss=0
  while read -r f; do
    n=$((n+1))
    [ -e "$P/$f" ] || { miss=$((miss+1)); continue; }
    cmp -s "$L/$f" "$P/$f" || { m=$((m+1)); echo "MOVER $f"; }
  done < /tmp/r11u250_dbm_$part.lst
  echo "$part: $m movers of $n databases ($miss without a pristine twin)"
done
