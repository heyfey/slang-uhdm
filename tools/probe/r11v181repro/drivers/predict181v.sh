#!/bin/bash
# predict181v.sh <law sweep workdir> <out>: fenced rows excluded by word boundary (fail closed)
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 3
W=$1; O=$2
( cd $W && find surelog uhdm2rtlil -name slang.uhdm; find probe -name '*.uhdm' ! -name 'golden*' ) | grep -Pv "$FENCED_RE" | sort > $O.list
echo "listed $(wc -l < $O.list) fenced_excluded $( (cd $W && find surelog uhdm2rtlil -name slang.uhdm) | grep -Pc "$FENCED_RE")"
(cd $W && xargs -P3 -n20 /tmp/v11u181_tools/predict181v < $O.list) | sort > $O
echo "predicted: $(awk '$2!="-"' $O | wc -l) of $(wc -l < $O)"
