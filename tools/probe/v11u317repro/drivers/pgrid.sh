#!/bin/bash
# (v11u317: copied from r11u317repro/drivers; rel maps v11u317repro/cases to v/)
# (r11u317: copied from v11u315repro/drivers)
# (r11u315: copied from r11u313repro/drivers)
# (r11u313: copied from v11u311repro/drivers)
# (v11u311: copied from r11u311repro/drivers)
# r11u313 pgrid.sh (from r11u311) <out> <case dir>... : grid.sh over the cases three at a time (one temporary file per case), then
# concatenated in argument order into <out>. Every line carries rc=.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; tmp=$(mktemp -d $S/pgrid.XXXX)
i=0; for c in "$@"; do i=$((i+1)); printf '%05d %s\n' $i "$c"; done | xargs -P 3 -L 1 bash -c 'bash '"$D"'/grid.sh '"$tmp"'/$0.txt $1'
cat $tmp/*.txt > $out; rm -rf $tmp
