#!/bin/bash
# v11u317 pgridv.sh <out> <case dir>... : gridv.sh three cases at a time, concatenated in argument order.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; tmp=$(mktemp -d $S/pgridv.XXXX)
i=0; for c in "$@"; do i=$((i+1)); printf '%05d %s\n' $i "$c"; done | xargs -P ${GJOBS:-3} -L 1 bash -c 'bash '"$D"'/gridv.sh '"$tmp"'/$0.txt $1'
cat $tmp/*.txt > $out; rm -rf $tmp
