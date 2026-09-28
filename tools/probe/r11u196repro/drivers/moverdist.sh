#!/bin/bash
# r11u196: for every byte mover of byteverify's output, the order-blind strict-record distance to golden in both sweeps
# (rowdist.sh), three rows at a time; prints `<corpus>/<mode>/<row> P dist/miss L dist/miss`.
# usage: moverdist.sh <byteverify.txt> <pristine sweep> <law sweep> > out   (fence: rowdist refuses fenced rows)
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
BV=$1; P=$2; L=$3
grep '^MOVER' $BV | sed -E 's#^MOVER \./([^/]+)/([^/]+)/(.+)-[0-9a-f]{8}/slang.uhdm.*#\1 \2 \3#' | \
  xargs -P 3 -L 1 bash -c 'r=$(bash '"$D"'/rowdist.sh $0 $1 $2 '"$P"' '"$L"' 2>&1 | awk "{print \$3\"/\"\$4}" | sed "s/dist=//; s/miss=//" | paste -sd" "); echo "$0/$1/$2 $r"'
