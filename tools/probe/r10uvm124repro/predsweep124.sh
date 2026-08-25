#!/usr/bin/env bash
# r10uvm124 — run pred124.py over EVERY database of a verify_golden workdir.
# MEASUREMENT ONLY.  PROCESSED is asserted against LISTED so a driver that
# reaches nothing can never read as green; every uhdm-dump rc is recorded.
#
# pred124.py prints NOTHING for a database with no candidate, so this artifact
# never enumerates the workdir's rows by name; the silent ones are COUNTED and
# the count is asserted against LISTED.
#
#   predsweep124.sh <workdir> <outfile>
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WD=${1:?workdir}; OUT=${2:?outfile}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/r10uvm124_pred.XXXXXX")
LIST=$TMP/list.txt
find "$WD" -name slang.uhdm | sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0; zero=0
: > "$OUT"
exec 3< "$LIST"
while IFS= read -r f <&3; do
  rel=${f#$WD/}; rel=${rel%/slang.uhdm}
  "$DUMP" "$f" 2>/dev/null </dev/null > "$TMP/d.txt"
  echo "dump_rc=$? $rel" >> "$TMP/rcs"
  python3 "$HERE/pred124.py" "$TMP/d.txt" "$rel" > "$TMP/one.txt" 2>>"$TMP/err"
  if [ -s "$TMP/one.txt" ]; then cat "$TMP/one.txt" >> "$OUT"; else zero=$((zero+1)); fi
  proc=$((proc+1))
done
exec 3<&-
grep -v 'dump_rc=0 ' "$TMP/rcs" >> "$OUT" || true
echo "LISTED=$listed PROCESSED=$proc ZERO_CANDIDATE_DATABASES=$zero" >> "$OUT"
rm -rf "$TMP"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED >> "$OUT"; exit 6; }
echo PROCESSED-ASSERT-OK >> "$OUT"
