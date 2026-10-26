#!/bin/bash
# epcensus3.sh <listfile> <outfile>: pristine, law, ver3 per earlier-pass case dir (bytes + rc)
P=/tmp/v11u433_bin/pristine; L=/tmp/v11u433_bin/law; V=/tmp/v11u433_bin/ver3
for v in "$P" "$L" "$V"; do [ -x "$v" ] || { echo "missing $v"; exit 2; }; done
while read c0; do
  c=/tmp/wt_v11u433/tools/probe/$c0; [ -d $c ] || { echo "NODIR $c0"; continue; }
  k=$(echo $c0 | sed 's|/|__|g'); SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
  GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
  o=/tmp/v11u433_scr/ep/$k; rm -rf $o; mkdir -p $o
  for t in p l v; do B=$P; [ $t = l ] && B=$L; [ $t = v ] && B=$V
    (cd $c && timeout 300 $B $SRC $GT --single-unit --nobuiltin -o $o/x.uhdm > /dev/null 2>&1; echo $? > $o/$t.rc); mv $o/x.uhdm $o/$t.uhdm 2>/dev/null; done
  pl=$( (cmp -s $o/p.uhdm $o/l.uhdm && [ "$(cat $o/p.rc)" = "$(cat $o/l.rc)" ]) && echo same || echo MOVED)
  lv=$( (cmp -s $o/l.uhdm $o/v.uhdm && [ "$(cat $o/l.rc)" = "$(cat $o/v.rc)" ]) && echo same || echo MOVED)
  echo "$c0 rc=$(cat $o/p.rc)/$(cat $o/l.rc)/$(cat $o/v.rc) p-l=$pl l-v=$lv"
  [ $pl = same ] && [ $lv = same ] && rm -f $o/*.uhdm
done < $1 > $2
echo CENSUSDONE >> $2
