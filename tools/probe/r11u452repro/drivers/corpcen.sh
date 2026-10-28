#!/bin/bash
# corpcen.sh <binary> <corpus surelog|uhdm2rtlil> <namelist> <workroot(15 chars, like /tmp/intr11u450)>:
# traced verify_golden run over the listed rows (both modes), then a byte
# comparison of every database against the master's control /tmp/intr11u450/<corpus>.
B=$1; K=$2; L=$3; W=$4; T=$W/tr_$K
[ -x "$B" ] || exit 2
re=$(python3 -c "import re,sys; print('^(' + '|'.join(re.escape(l.strip()) for l in open(sys.argv[1]) if l.strip()) + ')$')" $L)
rm -rf $W/$K $T; mkdir -p $T
(cd /tmp/wt_r11u452 && SLANG_UHDM=$B R11U452_TRACE=$T python3 scripts/verify_golden.py --corpus $K --mode both --out $W/$K.csv --workdir $W/$K --jobs 3 --filter "$re" > $W/$K.log 2>&1)
n=0; m=0
for f in $(cd $W/$K && find . -name slang.uhdm | sort); do
  n=$((n+1))
  c=/tmp/intr11u450/$K/$f
  if [ ! -f $c ]; then echo "NOCONTROL $f"; continue; fi
  cmp -s $W/$K/$f $c || { echo "MOVER $f"; m=$((m+1)); }
done
echo "databases=$n movers=$m"
for f in $T/*; do o=$(head -1 $f | sed 's/^OUT //'); echo "FIRES $o $(grep -v '^OUT' $f | awk '{print $1}' | sort | uniq -c | tr -s ' ' | tr '\n' ';')"; done | grep -v ' $' 
