#!/bin/bash
# predict.sh <list of databases> <out>: § importCopyTsInstByRole469 / § importEnumCloneHomeInst469's
# predicate (evidence/tools/pred469.cpp, built as $PRED) over pristine databases; rows with a nonzero
# third column are the predicted byte movers.  The list must already be fence-filtered.
PRED=${PRED:-/tmp/r11u469_tools/pred469}; [ -x "$PRED" ] || { echo "no $PRED"; exit 1; }
xargs -n 40 -P 3 "$PRED" < "$1" > "$2"
awk '$3>0' "$2" | wc -l
