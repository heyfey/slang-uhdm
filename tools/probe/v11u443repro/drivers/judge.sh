#!/bin/bash
# usage: judge.sh <case dir under /tmp/v11u443_cen> <file name>: fresh Surelog golden, then p/l/v against it
source /tmp/v11u443_env.sh || exit 2
SC=/tmp/v11u443_bin/strictcmp; [ -x $SC ] || exit 2
d=$1; f=$2
[ -s $d/golden/slpp_all/surelog.uhdm ] || (cd $d && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv $f -mt 0 -mp 0 -o golden >/dev/null 2>&1 </dev/null)
line="$(basename $d)"
[ -s $d/golden/slpp_all/surelog.uhdm ] || { echo "$line NO_GOLDEN"; exit 0; }
$UHDM_DUMP $d/golden/slpp_all/surelog.uhdm 2>/dev/null | sed 1d | sed "s#$d/##g; s#, id:[0-9]*##g" > $d/gdump.txt
for n in p l v; do
  cc=$($UHDM_CMP $d/golden/slpp_all/surelog.uhdm $d/$n.uhdm 2>&1 | wc -l)
  s=$($SC $d/golden/slpp_all/surelog.uhdm $d/$n.uhdm 2>&1 | tail -1)
  $UHDM_DUMP $d/$n.uhdm 2>/dev/null | sed 1d | sed "s#$d/##g; s#, id:[0-9]*##g" > $d/dump_$n.txt
  dd=$(diff $d/gdump.txt $d/dump_$n.txt | grep -c '^[<>]')
  line="$line	$n:cmp=$cc dist=$dd [$s]"
done
echo "$line"
