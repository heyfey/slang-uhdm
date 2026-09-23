#!/bin/bash
# switch check: every dut.sv under roots: pris vs lawz with env switches
OUT=${SWOUT:-/tmp/v11u111_swout}; PRIS=${PRIS:?pristine binary}; LAW=${LAW:?law binary}; mkdir -p $OUT; : > $OUT/result.txt
for root in "$@"; do
 while read -r rel <&3; do d=$(dirname "$rel"); w=$OUT/$(echo "$root/$d" | tr / _); mkdir -p $w
  run(){ (cd "$root/$d" && env $2 timeout 120 "$3" dut.sv --single-unit --nobuiltin -o "$w/$1.uhdm" </dev/null >/dev/null 2>&1); md5sum < "$w/$1.uhdm" 2>/dev/null | cut -c1-12; }
  p=$(run pris X=1 "$PRIS"); l=$(run law X=1 "$LAW")
  line="$root/$d law=$([ "$p" = "$l" ] && echo SAME || echo MOVED)"
  for sw in R11U111_OFF R11U111_F1_OFF R11U111_F1D_OFF R11U111_F1B_OFF R11U111_F2_OFF R11U111_F3_OFF R11U111_F5_OFF R11U111_F6_OFF; do
   s=$(run $sw "$sw=1" "$LAW"); t=$(echo $sw | sed 's/R11U111_//; s/_OFF//'); if [ "$s" = "$p" ]; then line="$line $t=P"; elif [ "$s" = "$l" ]; then line="$line $t=L"; else line="$line $t=X"; fi; done
  echo "$line" >> $OUT/result.txt; rm -f $w/*.uhdm
 done 3< <(cd "$root" && find . -name dut.sv | sort)
done
echo "ARMS=$(wc -l < $OUT/result.txt) OFF!=pris: $(grep -c ' OFF=[LX]' $OUT/result.txt; true)"
