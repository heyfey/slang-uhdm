#!/usr/bin/env bash
# r10uvm148 — run ct148cen over EVERY database of a PRISTINE verify_golden
# workdir and name this pass's mover set A PRIORI, before the patched binary
# has produced anything.  MEASUREMENT ONLY.
#
#   CEN=<ct148cen> predsweep148.sh <pristine-workdir> <out.cen>
#
# Ops traps paid for elsewhere and honoured here:
#   * LISTED / PROCESSED are asserted against each other;
#   * every ct148cen invocation records its OWN rc (an rc=139 must not read as
#     "no cells"), and NONZERO_RC is printed;
#   * the file list is read on fd 3 and every child gets </dev/null;
#   * each row is tagged with the database's MODE/NAME so a prediction can be
#     stated BY NAME.
set -u
CEN=${CEN:?set CEN=<ct148cen binary>}
WD=${1:?workdir}
OUT=${2:?out.cen}
: > "$OUT"
LIST=$(mktemp /tmp/r10uvm148_predlist.XXXXXX)
find "$WD" -name slang.uhdm | sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0; bad=0
exec 3< "$LIST"
while IFS= read -r f <&3; do
  d=$(dirname "$f"); base=$(basename "$d"); mode=$(basename "$(dirname "$d")")
  "$CEN" "$f" 2>/dev/null </dev/null | sed "s#^#DB=$mode/$base|#" >> "$OUT"
  rc=$?
  [ "$rc" -ne 0 ] && { bad=$((bad+1)); echo "RC=$rc $f"; }
  proc=$((proc+1))
done
exec 3<&-
rm -f "$LIST"
echo "LISTED=$listed PROCESSED=$proc NONZERO_RC=$bad"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
