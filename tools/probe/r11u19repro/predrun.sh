#!/usr/bin/env bash
# r11u19: run pred19 over every PRISTINE database of a sweep workdir.
set -u
ROOT=${1:?workdir}; OUT=${2:?out}
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
P=$(dirname "${BASH_SOURCE[0]}")/pred19.py
: > $OUT
n=0
while IFS= read -r f <&3; do
  n=$((n+1))
  rel=${f#$ROOT/}
  r=$($DUMP "$f" 2>/dev/null | python3 $P - 2>/dev/null | tail -1)
  l1=$(echo "$r" | awk '{print $4}'); l2=$(echo "$r" | awk '{print $6}')
  [ "${l1:-0}" != 0 ] || [ "${l2:-0}" != 0 ] && echo "$rel LAW1=$l1 LAW2=$l2" >> $OUT
done 3< <(find $ROOT -name slang.uhdm | sort)
echo "SCANNED=$n FLAGGED=$(grep -c . $OUT; true)" >> $OUT
