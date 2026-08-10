#!/bin/bash
# rd26.sh <basename> -- RAW dump diff of a run26 witness with the uid noise
# stripped.  `<` = GOLDEN, `>` = OURS.  Use when the projections say "equal"
# and uhdm-cmp still trips: the head may be a VECTOR SIZE, which no per-object
# projection can see.
D=/tmp/r10earl27_rep/out_$1
sed -E 's/id:[0-9]+//g; s#/[^ ,]*/##g' "$D/g.dump" > "$D/gn.txt"
sed -E 's/id:[0-9]+//g; s#/[^ ,]*/##g' "$D/o.dump" > "$D/on.txt"
diff "$D/gn.txt" "$D/on.txt"
echo "(rc=$?)"
