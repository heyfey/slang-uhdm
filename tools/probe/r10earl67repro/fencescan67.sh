#!/usr/bin/env bash
# r10earl67 CORPUS-WIDE FENCE SCAN — every database in a sweep workdir that
# carries the shape § genLpBitSelIdxOneHopFold67 would change (an ELAB
# cont_assign bit-select INDEX that is a ref_obj to a ONE-HOP gen-scope
# parameter, call arguments excluded).  Run on the PRISTINE sweep so the
# answer is "which rows could move", before the patched binary exists.
# MEASUREMENT ONLY.  usage: TSCEN67=… fencescan67.sh <workdir> [out]
set -u
CEN=${TSCEN67:?set TSCEN67}
HERE=$(cd "$(dirname "$0")" && pwd)
WD=${1:?workdir}; OUT=${2:-/dev/stdout}
n=0; hit=0
: > "$OUT"
while read -r db <&3; do
  n=$((n+1))
  rel=${db#$WD/}
  c=$(R66_INST=1 "$CEN" "$db" 2>/dev/null \
      | sed 's/\(ts\)\?span=[^ ]*:\([0-9]\+:[0-9]\+-[0-9]\+:[0-9]\+\)/\1span=\2/g' \
      | python3 "$HERE/predict67.py" /dev/stdin | awk '{print $2}')
  [ -z "$c" ] && c=0
  if [ "$c" != 0 ]; then hit=$((hit+1)); echo "$c $rel" >> "$OUT"; fi
done 3< <(find "$WD" -name slang.uhdm | sort)
echo "SCANNED=$n CARRYING_THE_SHAPE=$hit"
