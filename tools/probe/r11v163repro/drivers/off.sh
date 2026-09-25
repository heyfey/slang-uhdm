# off.sh <casedir> : pristine vs law with R11U163_OFF=1, bytes
c=$1; k=$(echo $c | md5sum | cut -c1-10); o=/tmp/v11u163_off; mkdir -p $o
(cd $c && rm -f $o/$k.p $o/$k.l && /tmp/v11u163_bin/pris.bin dut.sv --single-unit --nobuiltin -o $o/$k.p >/dev/null 2>&1; R11U163_OFF=1 /tmp/v11u163_bin/law.bin dut.sv --single-unit --nobuiltin -o $o/$k.l >/dev/null 2>&1)
cmp -s $o/$k.p $o/$k.l && echo "SAME $c" || echo "DIFF $c"
rm -f $o/$k.p $o/$k.l
