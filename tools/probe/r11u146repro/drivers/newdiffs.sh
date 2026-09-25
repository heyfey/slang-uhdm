#!/bin/bash
# newdiffs.sh <corpus> <mode> <name>: strict records that differ under the law and not under pristine
[ "$(echo $FENCED | wc -w)" = 4 ] || exit 1
c=$1; m=$2; n=$3
for wd in /tmp/r11u146_swP /tmp/r11u146_swL; do
  d=$(ls -d $wd/$c/$m/$n-* | head -1); g=$(grep -o 'goldens/[0-9a-f]*' $d/cmds.txt | head -1)
  /tmp/r11u146_bin/uhdm-strictcmp --max 100000 /home/heyfey/.cache/slang-uhdm-$g/golden.uhdm $d/slang.uhdm | paste - - - 2>/dev/null | grep '^#' > /tmp/r11u146_nd_$(basename $wd).txt
done
diff <(cut -f1 --complement /tmp/r11u146_nd_r11u146_swP.txt | sed 's/^[^A]*A:/A:/' | sort) <(cut -f1 --complement /tmp/r11u146_nd_r11u146_swL.txt | sed 's/^[^A]*A:/A:/' | sort) | head -${4:-40}
