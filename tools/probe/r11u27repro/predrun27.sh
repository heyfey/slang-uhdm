#!/usr/bin/env bash
# r11u27: run pred27 over every PRISTINE database of a sweep workdir.
set -u
ROOT=${1:?workdir}; OUT=${2:?out}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
P=${PRED:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/pred27.py}
: > $OUT
n=0
while IFS= read -r f <&3; do
  n=$((n+1))
  rel=${f#$ROOT/}
  r=$($DUMP "$f" 2>/dev/null | timeout 600 python3 $P - 2>/dev/null | tail -1)
  a=$(echo "$r" | sed -n 's/.*FB9=\([0-9]*\).*/\1/p'); a=${a:-0}
  b=$(echo "$r" | sed -n 's/.*FB7=\([0-9]*\).*/\1/p'); b=${b:-0}
  c=$(echo "$r" | sed -n 's/.*FB3=\([0-9]*\).*/\1/p'); c=${c:-0}
  d=$(echo "$r" | sed -n 's/.*FBX=\([0-9]*\).*/\1/p'); d=${d:-0}
  e=$(echo "$r" | sed -n 's/.*FU=\([0-9]*\).*/\1/p');  e=${e:-0}
  if [ "$a$b$c$d$e" != "00000" ]; then echo "$rel FB9=$a FB7=$b FB3=$c FBX=$d FU=$e" >> $OUT; fi
done 3< <(find $ROOT -name slang.uhdm | sort)
echo "SCANNED=$n FLAGGED=$(grep -c 'FB9=' $OUT; true)" >> $OUT
