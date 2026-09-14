#!/usr/bin/env bash
# r11u23: run pred23 over every PRISTINE database of a sweep workdir.
# Prints, per database, LAW=<flagged cells> ACT=<of those, carrying a
# vpiActual today> UNS=<of those, carrying an unsized constant in the Rhs>.
set -u
ROOT=${1:?workdir}; OUT=${2:?out}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
P=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/pred23.py
: > $OUT
n=0
while IFS= read -r f <&3; do
  n=$((n+1))
  rel=${f#$ROOT/}
  r=$($DUMP "$f" 2>/dev/null | python3 $P - 2>/dev/null | tail -1)
  l1=$(echo "$r" | awk '{print $4}')
  a1=$(echo "$r" | awk '{print $6}')
  u1=$(echo "$r" | awk '{print $8}')
  [ "${l1:-0}" != 0 ] && echo "$rel LAW=$l1 ACT=$a1 UNS=$u1" >> $OUT
done 3< <(find $ROOT -name slang.uhdm | sort)
echo "SCANNED=$n FLAGGED=$(grep -c 'LAW=' $OUT; true)" >> $OUT
