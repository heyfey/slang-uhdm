#!/usr/bin/env bash
# r10uvm127 — run pred127 (the A-PRIORI predictor) over every slang.uhdm of a
# verify_golden workdir built by the PRISTINE binary.  MEASUREMENT ONLY.
#
#   PRED=<pred127> predsweep127.sh <workdir>
#
# A database with nothing to predict prints NOTHING and is still COUNTED, so
# this artifact never enumerates a workdir's rows by name — the campaign does
# not spell the slang-fenced test names and a sweep artifact is no exception.
# PROCESSED is asserted against LISTED; the file list is read on fd 3 and every
# child gets </dev/null; every rc is recorded.
set -u
PRED=${PRED:?set PRED=<pred127 binary>}
WD=${1:?usage: predsweep127.sh <workdir>}
LIST=$(mktemp /tmp/r10uvm127_predlist.XXXXXX)
find "$WD" -name slang.uhdm -type f | sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0; zero=0; cand=0; cells=0; bad=0
exec 3< "$LIST"
while IFS= read -r f <&3; do
  out=$("$PRED" "$f" 2>/dev/null </dev/null); rc=$?
  proc=$((proc+1))
  [ "$rc" -ne 0 ] && bad=$((bad+1))
  if [ -z "$out" ]; then
    zero=$((zero+1))
  else
    cand=$((cand+1))
    n=$(printf '%s\n' "$out" | sed -n 's/^CELLS //p')
    cells=$((cells+${n:-0}))
    # name the row by its MODE/TEST directory only, never the workdir path
    rel=${f#"$WD"/}; rel=${rel%/slang.uhdm}
    printf '%s cells=%s\n' "$rel" "${n:-0}"
  fi
done
exec 3<&-
rm -f "$LIST"
echo "LISTED=$listed PROCESSED=$proc CANDIDATE_DATABASES=$cand ZERO_CANDIDATE_DATABASES=$zero CANDIDATE_CELLS=$cells NONZERO_RC=$bad"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
