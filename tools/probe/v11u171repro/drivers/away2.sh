#!/bin/bash
# away2.sh <casedir> <bin> : records multiset: golden vs pris vs <bin>; away = pristine-golden records the bin lost
C=$(readlink -f $1); B=$2; cd $C
FILES=$( [ -f files ] && cat files || echo dut.sv )
K=$(cat $FILES | sha1sum | cut -c1-16)-$(echo "$FILES" | tr '\n' ' ' | sha1sum | cut -c1-6)
n=$(echo $C | sed 's|.*/v11u171_cases/||' | tr / _)
S=/tmp/v11u171_scr/rec_$n; mkdir -p $S
[ -s $S/g.ms ] || { /tmp/v11u171_bin/uhdm-strictcmp --dump-a $S/g.rec --dump-b /dev/null /tmp/v11u171_gold/$K/golden.uhdm /tmp/v11u171_gold/$K/golden.uhdm >/dev/null 2>&1; cut -f2- $S/g.rec | sort > $S/g.ms; }
for b in pris $B; do /tmp/v11u171_bin/uhdm-strictcmp --dump-a $S/$b.rec --dump-b /dev/null /tmp/v11u171_caseout/$n.$b/ours.uhdm /tmp/v11u171_caseout/$n.$b/ours.uhdm >/dev/null 2>&1; cut -f2- $S/$b.rec | sort > $S/$b.ms; done
comm -12 $S/g.ms $S/pris.ms > $S/pg
echo "$n pris=$(comm -13 $S/g.ms $S/pris.ms | wc -l) $B=$(comm -13 $S/g.ms $S/$B.ms | wc -l) away=$(comm -23 $S/pg $S/$B.ms | wc -l)"
