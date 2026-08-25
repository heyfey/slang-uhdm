#!/usr/bin/env bash
# r10v124 verifier — independent a-priori mover predictor over a sweep workdir.
# A database is a CANDIDATE when its PRISTINE dump holds a method_func_call
# whose own VpiName or whose vpiPrefix VpiName carries a '['.
set -u
WD=${1:?}; OUT=${2:?}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEL=${CEL:?}
TMP=$(mktemp -d /tmp/v124_pred.XXXXXX)
find "$WD" -name slang.uhdm | sort > "$TMP/list.txt"
listed=$(wc -l < "$TMP/list.txt"); proc=0; zero=0
: > "$OUT"
exec 3< "$TMP/list.txt"
while IFS= read -r f <&3; do
  rel=${f#$WD/}; rel=${rel%/slang.uhdm}
  "$DUMP" "$f" 2>/dev/null </dev/null > "$TMP/d.txt"; rc=$?
  echo "dump_rc=$rc $rel" >> "$TMP/rcs"
  python3 "$CEL" "$TMP/d.txt" 2>/dev/null | awk -v R="$rel" -F'\t' '
     { v=$3
       split(v,a,"name="); n=a[2]; sub(/ span=.*/,"",n)
       p=""; if (index(v,"pfxname=")) { split(v,b,"pfxname="); p=b[2]; sub(/ pfxspan=.*/,"",p) }
       if (index(n,"[")||index(p,"[")) print R"\t"$2"\t"$3 }' > "$TMP/one.txt"
  if [ -s "$TMP/one.txt" ]; then cat "$TMP/one.txt" >> "$OUT"; else zero=$((zero+1)); fi
  proc=$((proc+1))
done
exec 3<&-
grep -v 'dump_rc=0 ' "$TMP/rcs" >> "$OUT" || true
echo "LISTED=$listed PROCESSED=$proc ZERO_CANDIDATE_DATABASES=$zero" >> "$OUT"
rm -rf "$TMP"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED >> "$OUT"; exit 6; }
echo PROCESSED-ASSERT-OK >> "$OUT"
