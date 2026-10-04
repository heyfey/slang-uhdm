#!/bin/bash
# v11u236repro: run every case dir under the given roots (default cases/) in both views with the named binaries.
# usage: run.sh <out> <jobs> <tag=binary[,ENV=VAL...]>... -- <casedir>...   (fail-closed on the fence through env.sh / case.sh)
set -u; HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 2
OUT=$1; J=$2; shift 2; TAGS=(); while [ "$1" != "--" ]; do TAGS+=("$1"); shift; done; shift
: > "$OUT"
for c in "$@"; do for el in 0 1; do for tb in "${TAGS[@]}"; do
  t=${tb%%=*}; rest=${tb#*=}; b=${rest%%,*}; ev=""; [ "$rest" != "$b" ] && ev=$(echo ${rest#*,} | tr ',' ' ')
  echo "EL=$el bash $HERE/case.sh $c $t $b $ev"
done; done; done | xargs -P "$J" -I{} bash -c '{}' >> "$OUT"
sort -o "$OUT" "$OUT"; echo "run: $(wc -l < "$OUT") runs"
