#!/usr/bin/env bash
# r10uvm197repro/censum197.sh — TOTAL a census file ROBUSTLY.
#
# cen197.sh runs its rows with `xargs -P`, so two rows' lines can INTERLEAVE
# and a CENSUM can end up glued to the tail of another row's line.  `grep
# '^CENSUM'` then MISSES it and every total reads low — which is exactly the
# class of silent undercount this campaign keeps paying for.  This totals on
# `grep -o` over the whole CENSUM record wherever it appears, and ASSERTS that
# the number of records found equals the number of rows processed.
#
#   usage: censum197.sh <census file>
set -u
F=${1:?census file}
REC='CENSUM [^ ]* cellsG=[0-9]* cellsO=[0-9]* AGREE=[0-9]* SIZE-DIFF=[0-9]* ONLY-GOLDEN=[0-9]* ONLY-OURS=[0-9]*'
grep -o "$REC" "$F" > "$F.records"
n=$(wc -l < "$F.records")
rows=$(grep -c '^RC ' "$F" || true)
awk -v n="$n" -v rows="$rows" '
  { for (i=1;i<=NF;i++) { split($i,a,"="); if (a[1] in S || a[1] ~ /cellsG|cellsO|AGREE|SIZE-DIFF|ONLY-GOLDEN|ONLY-OURS/) S[a[1]]+=a[2] } }
  END { printf "records=%d rows=%d cellsG=%d cellsO=%d AGREE=%d SIZE-DIFF=%d ONLY-GOLDEN=%d ONLY-OURS=%d %s\n",
        n, rows, S["cellsG"], S["cellsO"], S["AGREE"], S["SIZE-DIFF"], S["ONLY-GOLDEN"], S["ONLY-OURS"],
        (n==rows ? "RECORDS-COMPLETE" : "FATAL: RECORD COUNT != ROW COUNT") }
' "$F.records"
