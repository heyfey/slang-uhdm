#!/usr/bin/env bash
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=${ROOT:-$HERE}
LIST=${LIST:-/tmp/v98_arms_list.txt}
find "$ROOT" \( -name 'v98_*.sv' -o -name 'v98_*.v' \) -type f | sort > $LIST
n=0
exec 3< $LIST
while IFS= read -r s <&3; do
  n=$((n+1))
  for m in def elab; do MODE=$m NOSPAN=${NOSPAN:-} "$HERE"/v98run.sh "$s" </dev/null; done
done
exec 3<&-
echo "ARMS_LISTED=$(wc -l < $LIST) PROCESSED=$n"
