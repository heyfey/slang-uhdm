#!/bin/bash
# detana.sh: per row-mode, the number of distinct uhdm-dumps (header line dropped) among all runs of the law and fix
# binaries (3 + 3 concurrent runs), ordered and order-blind; the pristine runs the same.
. "$(dirname "$0")/env.sh"
O=/tmp/v11u196_det
for t in ${ROWS:-MiniAmiq SeqDriver SimpleUVM BuildUVMPkg Earlgrey_0_1}; do
 for m in default testflags; do
  for grp in "pris" "law fix"; do
   od=""; ob=""
   for b in $grp; do for i in 1 2 3; do f=$O/${t}_${m}_${b}_$i.uhdm; [ -s $f ] || continue
     $UHDM_DUMP $f 2>/dev/null | tail -n +2 > $O/d_$$.txt
     od="$od $(md5sum < $O/d_$$.txt | cut -c1-8)"; ob="$ob $(sort $O/d_$$.txt | md5sum | cut -c1-8)"; done; done
   echo "$t $m [$grp] dumps_distinct=$(echo $od | tr ' ' '\n' | sort -u | wc -l) orderblind_distinct=$(echo $ob | tr ' ' '\n' | sort -u | wc -l) (runs $(echo $od | wc -w))"
  done
 done
done
rm -f $O/d_$$.txt
