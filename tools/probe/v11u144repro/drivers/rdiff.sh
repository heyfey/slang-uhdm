#!/bin/bash
# v11u144_rdiff.sh <case rel> [elab]: strict differing records golden vs P and vs L
source /tmp/v11u144_env.sh
w=$(grep -lx "/tmp/v11u144_cases/$1" /tmp/v11u144_cw/*/dir | xargs -n1 dirname | while read d; do [ "$2" = elab ] && [ -d $d/sl ] && grep -q elab <<<"x" ; echo $d; done | head -1)
for t in ${TAGS:-P L}; do echo "=== $1 $t"; $STRICT_CMP --max ${MAX:-30} $w/golden.uhdm $w/$t.uhdm 2>&1 | grep -v '^$' | head -${LINES_:-40}; done
