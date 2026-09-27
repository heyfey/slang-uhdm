#!/bin/bash
# switchmatrix.sh <lawbin> [casedir-root...]: for every case-mode, the dump md5 of the law binary with each
# R11U184_<X>_OFF alone and with R11U184_OFF, against the pristine (tag P) and law (tag L) dumps grid.sh wrote.
# Prints per case-mode: the laws whose trace fires, and for each switch SAMEP / SAMEL / OTHER.
D=$(cd "$(dirname "$0")" && pwd)
b=$1; shift
roots=("$@"); [ ${#roots[@]} -eq 0 ] && roots=("$D/../cases")
SW="GENENUM TPENUM TPENUMCA MEMPAREN INCDECSEL LVIDXSEL GSTRAIL ROOTLV STREAMRD HPIDXCALL"
for root in "${roots[@]}"; do
  for c in $(find $root -name dut.sv -printf '%h\n' | sort); do
    for e in "" 1; do
      rel=$(ELAB=$e $D/grid.sh $c $b L R11U184_TRACE=1 | awk '{print $1}')
      w=/tmp/r11u184_g/$rel
      mp=$(md5sum < $w/P.dump | cut -c1-8); ml=$(md5sum < $w/L.dump | cut -c1-8)
      fires=$(grep -o 'R11U184 law [A-Z]*' $w/L.log | awk '{print $3}' | sort -u | tr '\n' ',')
      line="$rel fires=${fires:--} P=$mp L=$ml"
      for x in $SW ALL; do
        if [ $x = ALL ]; then v=R11U184_OFF=1; else v=R11U184_${x}_OFF=1; fi
        ELAB=$e $D/grid.sh $c $b S$x $v > /dev/null
        m=$(md5sum < $w/S$x.dump | cut -c1-8)
        r=OTHER; [ $m = $ml ] && r=SAMEL; [ $m = $mp ] && r=SAMEP; [ $mp = $ml ] && [ $m = $mp ] && r=SAME
        line="$line $x:$r"
      done
      echo "$line"
    done
  done
done
