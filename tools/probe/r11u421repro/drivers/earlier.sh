#!/bin/bash
# r11u421 earlier.sh <pristine bin> <law bin> <out>: every earlier-pass case dir of the sv-tests campaign (tools/probe/{r,v}11u4NNrepro, NN<21),
# path list built first and filtered on the fence list; pristine vs law: exit code and database md5
P=$1; F=$2; OUT=$3; : > $OUT
T=/tmp/r11u421_earl; mkdir -p $T
cd /tmp/wt_r11u421/tools/probe
ls -d r11u40[0-9]repro r11u41[0-9]repro r11u420repro v11u40[0-9]repro v11u41[0-9]repro v11u420repro 2>/dev/null | while read -r d; do find $d -name dut.sv; done | sort > $T/list.all
grep -v -F -f /tmp/r11u421_fenced.txt $T/list.all > $T/list
while read -r f <&3; do c=$(dirname $f); tg=$(echo $c | md5sum | cut -c1-12); TOP=""; [ -f $c/TOP ] && TOP="--top $(cat $c/TOP)"
 rm -f $T/p_$tg.uhdm $T/l_$tg.uhdm
 (cd $c && timeout 300 $P dut.sv $TOP --single-unit --nobuiltin -o $T/p_$tg.uhdm >/dev/null 2>&1 </dev/null); rp=$?
 (cd $c && timeout 300 $F dut.sv $TOP --single-unit --nobuiltin -o $T/l_$tg.uhdm >/dev/null 2>&1 </dev/null); rl=$?
 mp=$(md5sum < $T/p_$tg.uhdm 2>/dev/null | cut -c1-12); ml=$(md5sum < $T/l_$tg.uhdm 2>/dev/null | cut -c1-12)
 s=same; [ "$mp" != "$ml" ] && s=MOVED; [ "$rp" != "$rl" ] && s="$s RC"
 echo "$c rc=$rp/$rl $s" >> $OUT; rm -f $T/p_$tg.uhdm $T/l_$tg.uhdm
done 3< $T/list
echo "listed $(wc -l < $T/list.all) fence-filtered $(wc -l < $T/list) processed $(wc -l < $OUT)" >> $OUT
