#!/bin/bash
# pdiff.sh <case dir>: the strict comparator's differing records of pristine and law against the
# case's golden (grid.sh), and which records leave / enter.  Prints the two first records too.
c=$1; D=$(cd $(dirname $0) && pwd)
MAX=100000 $D/grid.sh $c /tmp/r11u158_bin/pris.bin PD > /dev/null
MAX=100000 $D/grid.sh $c ${LAWBIN:-/tmp/r11u158_bin/law6.bin} LD > /dev/null
rel=$(realpath $c | sed "s#.*/cases/##"); w=${GW:-/tmp/r11u158_g}/$rel
grep -E '^  [AB]:' $w/PD.strict | sort > $w/PD.rec; grep -E '^  [AB]:' $w/LD.strict | sort > $w/LD.rec
echo "$rel: pristine $(tail -1 $w/PD.strict) | law $(tail -1 $w/LD.strict) | records leave $(comm -23 $w/PD.rec $w/LD.rec | wc -l) enter $(comm -13 $w/PD.rec $w/LD.rec | wc -l)"
comm -13 $w/PD.rec $w/LD.rec | head -${SHOW:-6}
