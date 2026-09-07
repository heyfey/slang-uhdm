#!/usr/bin/env bash
# r10uvm201repro/censum201.sh — TOTAL a census file ROBUSTLY.
#
# cen201.sh runs its rows with `xargs -P`, so two rows' lines can INTERLEAVE
# and a CENSUM can end up glued to the tail of another row's line.  `grep
# '^CENSUM'` then MISSES it and every total reads low — which is exactly the
# class of silent undercount this campaign keeps paying for.  This totals on
# `grep -o` over the whole CENSUM record wherever it appears, and ASSERTS that
# the number of records found equals the number of rows processed.
#
# The SAME trap bites the `--pred` files, whose PREDSUM records interleave the
# same way, so this handles both: a file holding PREDSUM records is totalled on
# `cells=`, `RHSGAP=` and `LHSGAP=` instead.
#
#   usage: censum201.sh <census file>
set -u
F=${1:?census file}
if grep -q '^PREDSUM \|PREDSUM ' "$F" && ! grep -q 'CENSUM ' "$F"; then
  PREC='PREDSUM [^ ]* cells=[0-9]* RHSGAP=[0-9]* LHSGAP=[0-9]*'
  grep -o "$PREC" "$F" > "$F.records"
  n=$(wc -l < "$F.records")
  rows=$(grep -c '^RC ' "$F" || true)
  awk -v n="$n" -v rows="$rows" '
    { for (i=1;i<=NF;i++) { split($i,a,"="); if (a[1] ~ /^(cells|RHSGAP|LHSGAP)$/) S[a[1]]+=a[2] } }
    END { printf "records=%d rows=%d cells=%d RHSGAP=%d LHSGAP=%d %s\n",
          n, rows, S["cells"], S["RHSGAP"], S["LHSGAP"],
          (n==rows ? "RECORDS-COMPLETE" : "FATAL: RECORD COUNT != ROW COUNT") }
  ' "$F.records"
  exit 0
fi
REC='CENSUM [^ ]* cellsG=[0-9]* cellsO=[0-9]* AGREE=[0-9]* TS-DIFF=[0-9]* ONLY-GOLDEN=[0-9]* ONLY-OURS=[0-9]*'
grep -o "$REC" "$F" > "$F.records"
n=$(wc -l < "$F.records")
rows=$(grep -c '^RC ' "$F" || true)
awk -v n="$n" -v rows="$rows" '
  { for (i=1;i<=NF;i++) { split($i,a,"="); if (a[1] in S || a[1] ~ /cellsG|cellsO|AGREE|TS-DIFF|ONLY-GOLDEN|ONLY-OURS/) S[a[1]]+=a[2] } }
  END { printf "records=%d rows=%d cellsG=%d cellsO=%d AGREE=%d TS-DIFF=%d ONLY-GOLDEN=%d ONLY-OURS=%d %s\n",
        n, rows, S["cellsG"], S["cellsO"], S["AGREE"], S["TS-DIFF"], S["ONLY-GOLDEN"], S["ONLY-OURS"],
        (n==rows ? "RECORDS-COMPLETE" : "FATAL: RECORD COUNT != ROW COUNT") }
' "$F.records"
