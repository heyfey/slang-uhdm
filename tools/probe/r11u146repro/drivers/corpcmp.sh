#!/bin/bash
# corpcmp.sh <wdP> <wdL> <corpus> <mode> <name>: first strict record, pristine vs law
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "export FENCED" >&2; exit 1; }
P=$1; L=$2; c=$3; m=$4; n=$5
for f in $FENCED; do [ "$f" = "$n" ] && { echo "fenced: skipped"; exit 0; }; done
for wd in $P $L; do
  d=$(ls -d $wd/$c/$m/$n-* | head -1); g=$(grep -o 'goldens/[0-9a-f]*' $d/cmds.txt | head -1)
  echo "$(basename $wd): $(/tmp/r11u146_bin/uhdm-strictcmp --max 1 /home/heyfey/.cache/slang-uhdm-$g/golden.uhdm $d/slang.uhdm | head -3 | tr '\t' ' ' | tr '\n' '|' | tr -s ' ')"
done
