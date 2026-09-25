#!/bin/bash
# heads.sh <workdir> <out>: first strict record pair per STRICT_NOTEQUAL row-mode
WD=$1; OUT=$2; SC=/tmp/r11u146_bin/uhdm-strictcmp
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "heads.sh: export FENCED (four names) first" >&2; exit 1; }
: > $OUT
for corpus in surelog uhdm2rtlil; do
  awk -F, -v F="$FENCED" 'BEGIN{n=split(F,a," "); for(i=1;i<=n;i++) f[a[i]]=1} NR>1 && $3=="STRICT_NOTEQUAL" && !($1 in f){print $1","$2","$6}' $WD/$corpus.csv | while IFS=, read n m st; do
    d=$(ls -d $WD/$corpus/$m/$n-* 2>/dev/null | head -1); [ -z "$d" ] && continue
    g=$(grep -o 'goldens/[0-9a-f]*' $d/cmds.txt | head -1); gu=/home/heyfey/.cache/slang-uhdm-$g/golden.uhdm
    [ -f "$gu" ] || gu=$(ls $d/*golden*.uhdm 2>/dev/null | head -1)
    h=$(timeout 120 $SC --max 1 $gu $d/slang.uhdm 2>&1 | head -3 | tr '\t' ' ' | tr '\n' '|')
    echo "$corpus $m $n $st :: $h" >> $OUT
  done
done
