#!/bin/bash
# v11u276 bvall.sh <new sweep workdir> <pristine sweep workdir> <mirror root A> <mirror root B> (A and B of equal length):
# corpus byteverify on fence-filtered hard-link mirrors (r11u272repro/drivers/bvmirror.sh,
# tools/probe/r11v75repro/byteverify.sh with SELFCHECK=1), then the probe and the downstream slang-lane databases by
# cmp over path lists filtered by $FENCED (word boundary) before any file is opened.  Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bvall.sh: FENCED unset" >&2; exit 2; }
N=$1; P=$2; MA=$3; MB=$4; H=$(cd "$(dirname "$0")/../.." && pwd)
fre=$(echo $FENCED | tr ' ' '|')
bash $H/r11u272repro/drivers/bvmirror.sh $N $MA; bash $H/r11u272repro/drivers/bvmirror.sh $P $MB
SELFCHECK=1 bash $H/r11v75repro/byteverify.sh $MA $MB
for st in probe downstream; do
  n=0; m=0
  while read -r p; do n=$((n+1)); cmp -s "$N/$st/$p" "$P/$st/$p" || { m=$((m+1)); echo "MOVER $st $p"; }; done < <(cd $P/$st && find . -name '*.uhdm' -not -path '*/surelog/*' | sort | grep -vwE "$fre")
  echo "$st databases $n movers $m"
done
