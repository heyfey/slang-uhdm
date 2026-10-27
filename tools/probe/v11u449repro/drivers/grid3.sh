#!/bin/bash
# grid3.sh <root> <outfile>: every case dir under root on pristine, law, ver1 (+ ver1 with R11V449_OFF): rc, cmp, strict, md5
R=$1; O=$2; : > $O
for d in $(cd $R && ls -d */* | sort); do
  p=$(nice -n 19 bash /tmp/v11u449_run1.sh $R/$d /tmp/v11u449_bin/pristine pris)
  l=$(nice -n 19 bash /tmp/v11u449_run1.sh $R/$d /tmp/v11u449_bin/law law)
  k=$(echo $d|tr / _); tr=/tmp/v11u449_tr/v1_$k; rm -rf $tr; mkdir -p $tr
  v=$(nice -n 19 bash /tmp/v11u449_run1.sh $R/$d /tmp/v11u449_bin/ver1 ver1 R11U449_TRACE=$tr)
  vo=$(nice -n 19 bash /tmp/v11u449_run1.sh $R/$d /tmp/v11u449_bin/ver1 ver1off R11V449_OFF=1 | awk '{print $NF}')
  uo=$(nice -n 19 bash /tmp/v11u449_run1.sh $R/$d /tmp/v11u449_bin/ver1 ver1uoff R11U449_OFF=1 | awk '{print $NF}')
  echo "$p || ${l#* } || ${v#* } vOFF=$vo uOFF=$uo tr=$(cat $tr/* 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort | uniq -c | awk '{printf "%s:%s ", $2, $1}')" >> $O
done
