#!/bin/bash
# v11u206: wide byte controls over every tools/probe dut.sv dir (fenced names refused by word boundary, fail closed)
. /tmp/v11u206_drv/env.sh || exit 3
O=/tmp/v11u206_bytectl; mkdir -p $O
one() { d=$1; k=$(echo $d | md5sum | cut -c1-12); w=$O/w/$k; rm -rf $w; mkdir -p $w/tr
  ( cd $d && timeout 300 $VB/pris.bin dut.sv --single-unit --nobuiltin -o $w/p.uhdm > /dev/null 2>&1 )
  ( cd $d && R11U206_TRACE=$w/tr timeout 300 $VB/law.bin dut.sv --single-unit --nobuiltin -o $w/l.uhdm > /dev/null 2>&1 )
  laws=$(cat $w/tr/* 2>/dev/null | grep -v '^OUT ' | awk '{print $1}' | sort | uniq -c | awk '{printf "%s:%s ", $2, $1}')
  if [ ! -s $w/p.uhdm ] && [ ! -s $w/l.uhdm ]; then v=NODB; elif cmp -s $w/p.uhdm $w/l.uhdm; then v=SAME; rm -rf $w; else v=MOVED; fi
  echo "$d $v $laws"; }
export -f one; export O VB
find $REPO/tools/probe -name dut.sv -printf '%h\n' | grep -Pv "$FENCERE" | sort -u > $O/list.txt
xargs -a $O/list.txt -P3 -I{} bash -c 'one {}' | sort > $O/last.txt
echo "TALLY listed=$(wc -l < $O/list.txt) cases=$(wc -l < $O/last.txt) nodb=$(grep -c ' NODB' $O/last.txt) moved=$(grep -c ' MOVED' $O/last.txt) moved_without_firing=$(awk '$2=="MOVED" && NF==2' $O/last.txt | wc -l) fired_not_moved=$(awk '$2=="SAME" && NF>2' $O/last.txt | wc -l)"
