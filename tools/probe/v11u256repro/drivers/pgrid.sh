#!/bin/bash
# (v11u256) pgrid.sh <out> <jobs> <case dir>...: drivers/grid.sh (or $GRID, e.g. vgrid.sh) on each case dir, <jobs> case dirs at a time, each
# into its own part file, concatenated in case order into <out>. Needs B and S exported; grid.sh sources env.sh.
D=$(cd "$(dirname "$0")" && pwd); out=$1; J=$2; shift 2
P=$(mktemp -d /tmp/v11u256_pg.XXXX)
i=0; for c in "$@"; do i=$((i+1)); printf '%05d %s\n' $i "$c"; done |
  xargs -P $J -L 1 bash -c 'bash '"$D"'/${GRID:-grid.sh} '"$P"'/$0.txt $1'
cat $P/*.txt > $out; rm -rf $P
