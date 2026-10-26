#!/bin/bash
# path-normalized dump compare of kept sv-tests databases: <new wd> <ctl wd> <out>
source /tmp/v11u435_env.sh; [ -x "$UHDM_DUMP" ] || exit 9
N=$1; C=$2; O=$3; : > $O
cd $N/svtests/work && find . -name slang.uhdm | sort | while read f; do
  a=$(timeout 900 $UHDM_DUMP $N/svtests/work/$f 2>/dev/null | sed -E 's#/tmp/[A-Za-z0-9_]+/#/WD/#g' | md5sum | cut -c1-12)
  b=$(timeout 900 $UHDM_DUMP $C/svtests/work/$f 2>/dev/null | sed -E 's#/tmp/[A-Za-z0-9_]+/#/WD/#g' | md5sum | cut -c1-12)
  echo "$f $([ "$a" = "$b" ] && echo SAME || echo DIFF) $a $b" >> $O
done
echo done >> $O
