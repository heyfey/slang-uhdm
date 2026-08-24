#!/usr/bin/env bash
# r10uvm122 — run pred122.py over EVERY pristine database of a verify_golden
# workdir and print `<test> <mode> <candidate names…>` for the ones that carry
# the law's shape.  MEASUREMENT ONLY.
set -u
WD=${1:?pristine workdir}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
T=${TMP122:-/tmp/r10uvm122_pred}
mkdir -p "$T"
LIST=$T/dbs.txt
find "$WD" -name slang.uhdm | sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0; cand=0
exec 3< "$LIST"
while IFS= read -r f <&3; do
  d=$(dirname "$f"); rel=${d#$WD/}
  "$DUMP" "$f" 2>/dev/null </dev/null > "$T/one.dump"
  python3 "$HERE/pred122.py" "$T/one.dump" > "$T/one.names" 2>/dev/null
  proc=$((proc+1))
  if [ -s "$T/one.names" ]; then
    cand=$((cand+1))
    echo "CAND $rel $(tr '\n' ' ' < "$T/one.names")"
  fi
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc CANDIDATES=$cand"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
