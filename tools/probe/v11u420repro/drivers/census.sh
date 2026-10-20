#!/bin/bash
# census.sh <listfile>: per case dir, pristine vs law rc + md5 (same args as run1)
P=/tmp/v11u420_bin/pristine; L=/tmp/v11u420_bin/law; B=/tmp/wt_v11u420/tools/probe; O=/tmp/v11u420_cen; mkdir -p $O/p $O/l
while read d; do c=$B/${d#./}; SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES); GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
 rm -f $O/p/ours.uhdm $O/l/ours.uhdm
 (cd $c && timeout 300 $P $SRC $GT --single-unit --nobuiltin -o $O/p/ours.uhdm > /dev/null 2>&1; echo $? > $O/prc)
 (cd $c && timeout 300 $L $SRC $GT --single-unit --nobuiltin -o $O/l/ours.uhdm > /dev/null 2>&1; echo $? > $O/lrc)
 mp=$(md5sum < $O/p/ours.uhdm 2>/dev/null | cut -c1-8); ml=$(md5sum < $O/l/ours.uhdm 2>/dev/null | cut -c1-8)
 v=same; [ "$mp" != "$ml" ] && v=BYTES; [ "$(cat $O/prc)" != "$(cat $O/lrc)" ] && v=RC
 echo "$d $v prc=$(cat $O/prc) lrc=$(cat $O/lrc)"
done < $1
