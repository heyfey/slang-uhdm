#!/bin/bash
# r11u206: byte controls over evidence case dirs.  For every dut.sv under the given roots (paths naming a fenced test
# refused, word boundary, fail closed), run the pristine and the law binary (`dut.sv --single-unit --nobuiltin`, the
# probe command line) with R11U206_TRACE on the law run, and print one line per case:
#   <case> SAME|MOVED <fired laws>        and a final tally.  usage: bytectl.sh <law bin name in $B> <root>...
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LAW=$1; shift; O=/tmp/r11u206_bytectl; mkdir -p $O
fre=$(echo $FENCED | sed 's/ /|/g')
one() { d=$1; k=$(echo $d | md5sum | cut -c1-12); w=$O/$k; rm -rf $w; mkdir -p $w/tr
  ( cd $d && $B/pris.bin dut.sv --single-unit --nobuiltin -o $w/p.uhdm > /dev/null 2>&1 )
  ( cd $d && R11U206_TRACE=$w/tr $B/$LAW dut.sv --single-unit --nobuiltin -o $w/l.uhdm > /dev/null 2>&1 )
  laws=$(cat $w/tr/* 2>/dev/null | grep -v '^OUT ' | awk '{print $1}' | sort | uniq -c | awk '{printf "%s:%s ", $2, $1}')
  if [ ! -s $w/p.uhdm ] && [ ! -s $w/l.uhdm ]; then v=NODB; elif cmp -s $w/p.uhdm $w/l.uhdm; then v=SAME; else v=MOVED; fi
  echo "$d $v $laws"; }
export -f one; export B LAW O
for r in "$@"; do find $r -name dut.sv -printf '%h\n'; done | grep -Evw "$fre" | sort -u | xargs -P3 -I{} bash -c 'one {}' | sort > $O/last.txt
cat $O/last.txt; echo "TALLY cases=$(wc -l < $O/last.txt) nodb=$(grep -c ' NODB' $O/last.txt) moved=$(grep -c ' MOVED' $O/last.txt) moved_without_firing=$(awk '$2=="MOVED" && NF==2' $O/last.txt | wc -l)"
