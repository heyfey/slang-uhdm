#!/bin/bash
# (v11u256: copied from r11u256repro/drivers)
# (v11u256: the list files go to $S; the copy wrote them to a hard-coded /tmp/r11u256_s)
# (r11u256: copied from r11u254repro/drivers)
# (r11u254: copied from r11u252repro/drivers)
# (r11u250) dbmovers.sh <law sweep wd> <pristine sweep wd>: byte movers among the probe databases (probe/*.uhdm) and the
# downstream slang lanes (downstream/<test>/slang/*.uhdm) of two gate sweeps. Path lists are built first and filtered
# by $FENCED (word boundary, fail closed) before any file is opened; the corpus databases are byteverify's.
[ -n "$S" ] && mkdir -p "$S" || { echo "dbmovers.sh: export S" >&2; exit 2; }
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "dbmovers.sh: FENCED not 4 names" >&2; exit 2; }
fre=$(echo $FENCED | tr ' ' '|'); L=$1; P=$2
for part in probe downstream; do
  (cd $L && find $part -name '*.uhdm' -path '*' | sort) | grep -vwE "$fre" > ${S:?}/dbm_$part.lst
  [ "$part" = downstream ] && grep '/slang/' ${S:?}/dbm_$part.lst > ${S:?}/dbm_$part.lst2 && mv ${S:?}/dbm_$part.lst2 ${S:?}/dbm_$part.lst
  n=0; m=0; miss=0
  while read -r f; do
    n=$((n+1))
    [ -e "$P/$f" ] || { miss=$((miss+1)); continue; }
    cmp -s "$L/$f" "$P/$f" || { m=$((m+1)); echo "MOVER $f"; }
  done < ${S:?}/dbm_$part.lst
  echo "$part: $m movers of $n databases ($miss without a pristine twin)"
done
