#!/usr/bin/env bash
# r10uvm181repro/predict181.sh — run predict181 over every slang.uhdm in a
# PRISTINE verify_golden workdir and list the databases that will move, BY NAME.
# MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
#
#   usage: predict181.sh <workdir> <predict181 bin> <raw-log-path>
#
# The RAW LOG (one line per database, including the non-movers) is written to
# <raw-log-path>, which MUST be scratch: it names every row in the corpus and
# would therefore SPELL the four slang-fenced test names in a committed
# artefact.  Only this script's STDOUT — the counts plus the MOVER lines — is
# fit to commit, and it is fenced by construction because a fenced row is a
# SLANG_REJECT with no `slang.uhdm` to read at all.  The count of rows that
# produced no database is reported as NO_DB so the arithmetic still closes.
#
# fd-3 list with children </dev/null (a stdin-list is swallowed by the first
# child), and PROCESSED asserted against LISTED (RESUME.md §9).
set -u
WD=${1:?workdir}; P=${2:?predict bin}; RAW=${3:?raw log path}
: > "$RAW"
n=0
while IFS= read -r f <&3; do
  d=$(dirname "$f")
  "$P" "$f" "$(basename "$(dirname "$d")")/$(basename "$d")" </dev/null >> "$RAW" 2>&1
  n=$((n+1))
done 3< <(find "$WD" -name slang.uhdm | sort)
proc=$(grep -c ' PREDICT \| RESTORE_FAIL' "$RAW"; true)
echo "LISTED=$n PROCESSED=$proc"
[ "$proc" -eq "$n" ] || { echo "PROCESSED-ASSERT-FAILED"; exit 6; }
echo "PROCESSED-ASSERT-OK"
echo "NO_DB (rows with no slang.uhdm to read, fenced rows among them)=$(( $(find "$WD" -maxdepth 2 -mindepth 2 -type d | wc -l) - n ))"
echo "MOVERS=$(grep -c ' MOVER$' "$RAW"; true)"
grep ' MOVER$' "$RAW" | sort
