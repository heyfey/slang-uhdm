#!/bin/bash
# usage: perlaw.sh <grid.tsv> <law binary>: for each case, which single R11U445_<LAW>_OFF switch restores the pris md5
G=$1; L=$2; WR=${WR:-/tmp/r11u445_grid}
SW="SHADOWBLK MODPARAM PARAMREAD PARAMNOSHADOW IFACELVDECL PKGLVDECL"
[ -x "$L" ] || exit 2
while IFS=$'\t' read -r key slrc pris law rest; do
  d=$WR/$(echo $key | tr / _); pm=$(echo "$pris" | sed 's/.*md5=\([0-9a-f]*\).*/\1/'); lm=$(echo "$law" | sed 's/.*md5=\([0-9a-f]*\).*/\1/')
  if [ "$pm" = "$lm" ]; then echo "$key	byte-identical"; continue; fi
  moved=""
  for s in $SW; do
    rm -f $d/out_pl.uhdm
    (cd $d && env R11U445_${s}_OFF=1 timeout 300 $L dut.sv --single-unit --nobuiltin -o out_pl.uhdm >/dev/null 2>&1 </dev/null)
    m=$(md5sum < $d/out_pl.uhdm | cut -c1-8)
    [ "$m" != "$lm" ] && moved="$moved $s$([ "$m" = "$pm" ] && echo '=pristine')"
  done
  echo "$key	switches moving bytes:$moved"
done < $G
