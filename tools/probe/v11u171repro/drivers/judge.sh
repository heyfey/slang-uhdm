#!/bin/bash
# judge.sh <rel dut.sv> : golden vs pris / fix2 boundary outputs; strict verdicts + record-multiset away
source /tmp/v11u171_scr/env.sh
rel=$1; d=$(dirname $rel); k=$(echo $d | tr / _); o=/tmp/v11u171_bnd/w/$k
echo "$d" | grep -Pq "$FENCED_RE" && { echo FENCED; exit 3; }
C=/tmp/wt_v11u171/$d
KEY=$(cat $C/dut.sv | sha1sum | cut -c1-16)-$(echo dut.sv | tr '\n' ' ' | sha1sum | cut -c1-6); GC=/tmp/v11u171_gold/$KEY; mkdir -p $GC
if [ ! -s $GC/golden.uhdm ]; then rm -rf $GC/w; mkdir -p $GC/w; (cd $C && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $GC/w > $GC/surelog.log 2>&1 </dev/null); g=$(find $GC/w -name '*.uhdm' | head -1); [ -n "$g" ] && cp $g $GC/golden.uhdm; rm -rf $GC/w; fi
[ -s $GC/golden.uhdm ] || { echo "$d SURELOG_FAIL"; exit 0; }
v() { $UHDM_CMP $GC/golden.uhdm $1 > $o/cmp.$2 2>&1; c=$?; /tmp/v11u171_bin/uhdm-strictcmp $GC/golden.uhdm $1 > $o/st.$2 2>&1; echo "cmp=$c/$(wc -l < $o/cmp.$2) $(tail -n 1 $o/st.$2 | tr ' ' '_') $(grep '^fields' $o/st.$2 | sed 's/fields: //; s/ /,/g')"; }
[ -s $o/g.ms ] || { /tmp/v11u171_bin/uhdm-strictcmp --dump-a $o/g.rec --dump-b /dev/null $GC/golden.uhdm $GC/golden.uhdm >/dev/null 2>&1; cut -f2- $o/g.rec | sort > $o/g.ms; }
for b in p f; do /tmp/v11u171_bin/uhdm-strictcmp --dump-a $o/$b.rec --dump-b /dev/null $o/$b.uhdm $o/$b.uhdm >/dev/null 2>&1; cut -f2- $o/$b.rec | sort > $o/$b.ms; done
comm -12 $o/g.ms $o/p.ms > $o/pg
echo "$d | P: $(v $o/p.uhdm p) | F: $(v $o/f.uhdm f) | recs notGolden p=$(comm -13 $o/g.ms $o/p.ms | wc -l) f=$(comm -13 $o/g.ms $o/f.ms | wc -l) away=$(comm -23 $o/pg $o/f.ms | wc -l)"
