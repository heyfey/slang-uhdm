#!/usr/bin/env bash
# r10uvm145 — run ct145cen over every database of a PRISTINE verify_golden
# workdir and hand the .cen files to pred145.py.  MEASUREMENT ONLY.
#   CEN=<ct145cen> predsweep145.sh <workdir> <outdir>
# Every invocation records its own rc: an rc=139 must not read as "no cells".
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CEN=${CEN:?set CEN=<ct145cen binary>}
WD=${1:?workdir}
OUT=${2:?outdir}
mkdir -p "$OUT"
LIST=$OUT/dbs.txt
find "$WD" -name slang.uhdm | sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0; bad=0
exec 3< "$LIST"
while IFS= read -r db <&3; do
  rel=${db#$WD/}; rel=${rel%/slang.uhdm}; key=${rel//\//__}
  "$CEN" "$db" > "$OUT/$key.cen" 2>"$OUT/$key.err" </dev/null
  rc=$?
  echo "$key rc=$rc" >> "$OUT/rcs.txt"
  [ "$rc" -eq 0 ] || bad=$((bad+1))
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc NONZERO_RC=$bad"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
python3 "$HERE/pred145.py" "$OUT"/*.cen
