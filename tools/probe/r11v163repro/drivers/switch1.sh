# sw1.sh <casedir>: trace set; then for single-law cases, law with that switch off == pristine bytes?
c=$1; k=$(echo $c | md5sum | cut -c1-10); o=/tmp/v11u163_sw1; mkdir -p $o
cd $c || exit
laws=$(R11U163_TRACE=1 /tmp/v11u163_bin/law.bin dut.sv --single-unit --nobuiltin -o $o/$k.t 2>&1 >/dev/null | grep -o 'R11U163_TRACE [A-Z]*' | awk '{print $2}' | sort -u | tr '\n' ' ')
rm -f $o/$k.t $o/$k.p
/tmp/v11u163_bin/pris.bin dut.sv --single-unit --nobuiltin -o $o/$k.p >/dev/null 2>&1
res=""
for L in $laws; do
  rm -f $o/$k.s; env R11U163_${L}_OFF=1 /tmp/v11u163_bin/law.bin dut.sv --single-unit --nobuiltin -o $o/$k.s >/dev/null 2>&1
  rm -f $o/$k.l; /tmp/v11u163_bin/law.bin dut.sv --single-unit --nobuiltin -o $o/$k.l >/dev/null 2>&1
  a=$(cmp -s $o/$k.s $o/$k.p && echo P || (cmp -s $o/$k.s $o/$k.l && echo L || echo X))
  res="$res $L:$a"
done
rm -f $o/$k.*
echo "$c |$laws|$res"
