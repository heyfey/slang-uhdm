#!/bin/bash
# boundary.sh <outdir>: the fix's byte control over every single-file tools/probe/**/dut.sv outside this directory
# (the landed grids of every pass, the fenced paths refused by word boundary): fix.bin vs law.bin, `dut.sv
# --single-unit --nobuiltin`, children on </dev/null, the list read on fd 3; SAME / MOVER / NODB per case and the
# PROCESSED == LISTED check.  Fail-closed on $FENCED.
source /tmp/wt_r11u185/tools/probe/r11u185verify/drivers/env.sh || exit 2
O=$1; mkdir -p $O/db
fre=$(echo $FENCED | sed 's/ /|/g')
find /tmp/wt_r11u185/tools/probe -name dut.sv | grep -v '/r11u185verify/' | grep -Evw "($fre)" | sort > $O/list.txt
one() { d=$(dirname $1); k=$(echo ${d#/tmp/wt_r11u185/tools/probe/} | tr / _); r=""
  for t in L:$LAW F:$FIX; do rm -f $O/db/$k.${t%%:*}.uhdm
    (cd $d && timeout 120 ${t#*:} dut.sv --single-unit --nobuiltin -o $O/db/$k.${t%%:*}.uhdm > /dev/null 2>&1 < /dev/null); r="$r ${t%%:*}rc=$?"; done
  a=$O/db/$k.L.uhdm; b=$O/db/$k.F.uhdm
  if [ -s $a ] && [ -s $b ]; then cmp -s $a $b && v=SAME || v=MOVER; elif [ -s $a ] || [ -s $b ]; then v=PRESENCE; else v=NODB; fi
  [ $v = SAME ] || [ $v = NODB ] && rm -f $a $b
  echo "$v ${d#/tmp/wt_r11u185/tools/probe/}$r"; }
export -f one; export O LAW FIX
xargs -P 4 -I{} bash -c 'one {}' < $O/list.txt 3<&- > $O/result.txt
echo "listed $(wc -l < $O/list.txt) processed $(wc -l < $O/result.txt) $(awk '{print $1}' $O/result.txt | sort | uniq -c | tr '\n' ' ')"
