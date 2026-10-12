#!/bin/bash
# v11u294 controls.sh <pristine bin> <law bin> <list of case dut.sv paths relative to tools/probe> <out>: both views of
# every listed case dir on both binaries through case.sh; one line per case-view and binary.  The list is built and
# filtered by $FENCED before this runs; each path is re-checked here (fail-closed).
H=$(cd "$(dirname "$0")" && pwd); source "$H/env.sh" || exit 2
P=$1; L=$2; LST=$3; O=$4; TP=$(cd "$H/../.." && pwd)
while read -r f; do d=$(dirname "$f"); echo "$f" | grep -Pq "$FENCERE" && continue
  for v in d e; do echo "$d $v pristine $P"; echo "$d $v law $L"; done; done < "$LST" |
  xargs -P ${CJ:-3} -L 1 bash -c 'echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$TP"'/$0 $3 $1 3)"' | sort > "$O"
wc -l < "$O"
