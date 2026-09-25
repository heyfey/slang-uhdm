#!/bin/bash
# changecheck.sh <pristine sweep wd> <law sweep wd> <sweep.log>: for every CHANGE / CONVERSION line of the law
# sweep log, the strict comparator's field summary on the pristine and on the law database, so an unmasking
# (pristine "walk diverged", law aligned) is told apart from a new difference.
P=$1; L=$2; LOG=$3; D=$(cd "$(dirname "$0")" && pwd); SC=${STRICT_CMP:-/tmp/r11u151_bin/strictcmp}
grep -E '^(CHANGE|CONVERSION) ' $LOG | while read -r kind name rest; do
  set -- $rest
  if [[ "$name" == */* ]]; then   # a probe case
    g=$(python3 $D/probegold.py $name | awk '{print $2}'); f=$(echo $name | sed 's#/#__#g').uhdm
    pa=$P/probe/$f; la=$L/probe/$f
    echo "$kind probe $name"
  else
    mode=$1
    for corpus in surelog uhdm2rtlil; do
      pd=$(ls -d $P/$corpus/$mode/$name-* 2>/dev/null | head -1); [ -n "$pd" ] || continue
      ld=$(ls -d $L/$corpus/$mode/$name-* | head -1)
      g=/home/heyfey/.cache/slang-uhdm-$(grep -o 'goldens/[0-9a-f]*' $pd/cmds.txt)/golden.uhdm
      pa=$pd/slang.uhdm; la=$ld/slang.uhdm; echo "$kind $corpus $mode $name"; break
    done
  fi
  echo "   pristine: $($SC --max 0 $g $pa 2>&1 | grep -E '^(fields|STRICT|objects)' | tr '\n' ' ')"
  echo "   law     : $($SC --max 0 $g $la 2>&1 | grep -E '^(fields|STRICT|objects)' | tr '\n' ' ')"
done
