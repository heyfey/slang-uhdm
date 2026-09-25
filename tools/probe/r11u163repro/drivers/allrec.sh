#!/bin/bash
# allrec.sh <sweepdir> <out>: for every STRICT_NOTEQUAL row-mode of the sweep's surelog + uhdm2rtlil csvs,
# the full strict record diff (--max 0 count line + first 12 records) into <out>/<corpus>.<mode>.<test>.txt.
# FAIL-CLOSED on $FENCED (refuses without it, skips fenced names).
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "allrec.sh: export FENCED (four names) first" >&2; exit 1; }
W=$1; O=$2; mkdir -p $O; D=$(cd $(dirname $0) && pwd)
for c in surelog uhdm2rtlil; do
  grep ',STRICT_NOTEQUAL,' $W/$c.csv | cut -d, -f1,2 | while IFS=, read t m; do
    skip=0; for f in $FENCED; do [ "$t" = "$f" ] && skip=1; done; [ $skip = 1 ] && continue
    $D/rowrec.sh $W $c $m $t 12 > $O/$c.$m.$t.txt 2>&1
  done
done
