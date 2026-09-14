#!/usr/bin/env bash
# r11u25: run pred25 over every PRISTINE database of a sweep workdir.
# Per database: F1F/F1O (the fill-size face) and F2 (the dropped-binding face).
set -u
ROOT=${1:?workdir}; OUT=${2:?out}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
P=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/pred25.py
: > $OUT
n=0
while IFS= read -r f <&3; do
  n=$((n+1))
  rel=${f#$ROOT/}
  r=$($DUMP "$f" 2>/dev/null | timeout 600 python3 $P - 2>/dev/null | tail -1)
  a=$(echo "$r" | sed -n 's/.*F1F=\([0-9]*\).*/\1/p')
  b=$(echo "$r" | sed -n 's/.*F1O=\([0-9]*\).*/\1/p')
  c=$(echo "$r" | sed -n 's/.*F2=\([0-9]*\).*/\1/p')
  a=${a:-0}; b=${b:-0}; c=${c:-0}
  if [ "$a$b$c" != "000" ]; then echo "$rel F1F=$a F1O=$b F2=$c" >> $OUT; fi
done 3< <(find $ROOT -name slang.uhdm | sort)
echo "SCANNED=$n FLAGGED=$(grep -c 'F1F=' $OUT; true)" >> $OUT
