#!/bin/bash
# pacmp <griddir>: param_assign rhs multiset: golden vs pris vs law
source $(dirname $0)/env.sh
d=$1
for t in gold/golden pris law; do [ -s $d/$t.uhdm ] && $UHDM_DUMP $d/$t.uhdm 2>/dev/null | python3 -c "
import sys;sys.argv=['x','/dev/stdin'];exec(open('$(dirname $0)/pa.py').read())" | sort > $d/$(basename $t).pa; done
g=$d/golden.pa; p=$d/pris.pa; l=$d/law.pa
pa=$(comm -23 $p $g | wc -l); la=$(comm -23 $l $g | wc -l)
brk=$(comm -12 $p $g | comm -23 - $l | wc -l)   # golden-agreeing pris lines lost by law
echo "$d away(pris)=$pa away(law)=$la lost_golden_lines=$brk"
