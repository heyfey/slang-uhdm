#!/bin/bash
# recs.sh <casedir> : records multiset compare (constants' value by file/line/col) golden vs pris vs law, for stage1-failing cases
C=$(readlink -f $1); cd $C
FILES=$( [ -f files ] && cat files || echo dut.sv )
K=$(cat $FILES | sha1sum | cut -c1-16)-$(echo "$FILES" | tr '\n' ' ' | sha1sum | cut -c1-6)
n=$(echo $C | sed 's|.*/v11u171_cases/||' | tr / _)
S=/tmp/v11u171_scr/rec_$n; mkdir -p $S
/tmp/v11u171_bin/uhdm-strictcmp --dump-a $S/g.rec --dump-b /dev/null /tmp/v11u171_gold/$K/golden.uhdm /tmp/v11u171_gold/$K/golden.uhdm >/dev/null 2>&1
for b in ${BINS:-pris law}; do /tmp/v11u171_bin/uhdm-strictcmp --dump-a $S/$b.rec --dump-b /dev/null /tmp/v11u171_caseout/$n.$b/ours.uhdm /tmp/v11u171_caseout/$n.$b/ours.uhdm >/dev/null 2>&1; done
# strip depth column; multiset
for f in g pris law; do cut -f2- $S/$f.rec | sort > $S/$f.ms; done
a=$(comm -13 $S/g.ms $S/pris.ms | wc -l); b=$(comm -13 $S/g.ms $S/law.ms | wc -l)
echo "$n recs oursNotGolden pris=$a X(golden $(wc -l < $S/g.ms), pris $(wc -l < $S/pris.ms), law $(wc -l < $S/law.ms))"
