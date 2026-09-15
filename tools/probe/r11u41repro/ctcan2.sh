#!/usr/bin/env bash
# r10oth7 — ctcan2.sh, the SUPPLEMENTARY canary check.
#
#   usage: EXPECT_UNKNOWN=<n> ctcan2.sh <baseline.csv> <fresh.csv>
#
# WHY THIS EXISTS, and it is a CORRECTION of this pass's own first write-up.
# `tools/probe/r10uvm52repro/canaries.sh` carries a 33-name NAMES list.  The
# campaign brief names MORE canaries than that list contains, and r10oth7's
# README first claimed those extra names were "at baseline" while citing
# canaries.sh as the evidence.  canaries.sh CANNOT see them: a name it does not
# carry is never looked up, so it can never be reported as changed.  That is the
# campaign's "a cited guard that does not exist" trap, committed by this pass and
# caught at integration by AUDITING the guard's own list instead of trusting the
# citation.
#
# AUDITED GAP (brief-named, absent from canaries.sh's NAMES):
#   exact names : TypespecExpr ClogCast 2DFunctionArg PartSelect4
#   families    : EvalFunc*  ParamFile*  Black*  (canaries.sh has only
#                 BlackParrotComplex of the Black family)
# Everything else the brief names IS in canaries.sh and is checked there; run
# BOTH scripts.  Neither supersedes the other.
#
# ONE NAMES LIST, TWO CORPORA -- so some patterns legitimately match nothing.
# This script therefore uses canaries.sh's proven convention: it COUNTS the
# unmatched patterns and requires the caller to state the expected number, so an
# unmatched pattern is never silently tolerated and never silently fatal either.
# The two expected numbers were MEASURED here, not assumed:
#   EXPECT_UNKNOWN=1 on a SURELOG csv -- `2DFunctionArg`, which is u2r-only.
#   EXPECT_UNKNOWN=6 on a UHDM2RTLIL csv -- `TypespecExpr`, `ClogCast`,
#     `PartSelect4` and all three families, which are surelog-only.
# With EXPECT_UNKNOWN unset, ANY unmatched pattern is fatal.
#
# GUARDS, each with a control exercised at integration (see README §4.2):
#   * a pattern matching NO row in EITHER csv prints UNKNOWN-PATTERN and is
#     fatal unless EXPECT_UNKNOWN accounts for it EXACTLY -- a typo'd pattern
#     raises the count above the expectation and can never read as green.
#   * a name present in one csv and not the other prints ABSENT, not OK.
#   * the whole ROW is compared (status AND the dump column), not the status
#     alone, because a dump-column-only regression moves no status.
# CONVENTION: LHS is ALWAYS golden(Surelog), RHS is ALWAYS ours -- but this
# script reads the harness CSVs, so it compares BASELINE rows to FRESH rows and
# never touches a database.
set -u
BASE=${1:?baseline csv}
FRESH=${2:?fresh csv}
[ -f "$BASE" ]  || { echo "FATAL: missing baseline $BASE"; exit 9; }
[ -f "$FRESH" ] || { echo "FATAL: missing fresh $FRESH"; exit 9; }

EXACT="TypespecExpr ClogCast 2DFunctionArg PartSelect4"
PREFIX="EvalFunc ParamFile Black"

ok=0; changed=0; absent=0; unknown=0

check_row() {  # <name> <mode> <baseline-row> <fresh-row>
  local n=$1 m=$2 b=$3 f=$4
  if [ -z "$b" ] && [ -z "$f" ]; then return; fi
  if [ -z "$b" ] || [ -z "$f" ]; then
    printf '  %-34s %-9s ABSENT   base=[%s] fresh=[%s]\n' "$n" "$m" "$b" "$f"
    absent=$((absent+1)); return
  fi
  if [ "$b" = "$f" ]; then
    printf '  %-34s %-9s OK       %s\n' "$n" "$m" "$b"
    ok=$((ok+1))
  else
    printf '  %-34s %-9s CHANGED  %s -> %s\n' "$n" "$m" "$b" "$f"
    changed=$((changed+1))
  fi
}

# One name, both modes.  The compared value is status + dump column.
do_name() {
  local n=$1 seen=0
  for m in default testflags; do
    b=$(awk -F, -v n="$n" -v m="$m" '$1==n && $2==m {print $3"/"$NF}' "$BASE")
    f=$(awk -F, -v n="$n" -v m="$m" '$1==n && $2==m {print $3"/"$NF}' "$FRESH")
    [ -n "$b" ] && seen=1
    [ -n "$f" ] && seen=1
    check_row "$n" "$m" "$b" "$f"
  done
  return $seen
}

echo "== exact names canaries.sh does NOT carry =="
for n in $EXACT; do
  if do_name "$n"; then
    printf '  %-34s %-9s UNKNOWN-PATTERN (no row in EITHER csv, either mode)\n' "$n" "-"
    unknown=$((unknown+1))
  fi
done

echo "== families canaries.sh does NOT carry (prefix match) =="
for p in $PREFIX; do
  # Union of the names each csv actually has, so a name that VANISHED from the
  # fresh csv still gets an ABSENT row rather than disappearing from the report.
  names=$( { awk -F, -v p="$p" 'index($1,p)==1 {print $1}' "$BASE";
             awk -F, -v p="$p" 'index($1,p)==1 {print $1}' "$FRESH"; } \
           | sort -u )
  if [ -z "$names" ]; then
    printf '  %-34s %-9s UNKNOWN-PATTERN (prefix matched NOTHING in either csv)\n' "$p*" "-"
    unknown=$((unknown+1)); continue
  fi
  echo "  -- $p* : $(echo "$names" | wc -l) name(s)"
  for n in $names; do do_name "$n" || true; done
done

echo "---- ctcan2 rows: ok=$ok changed=$changed absent=$absent unknown-patterns=$unknown"
EXP=${EXPECT_UNKNOWN:-0}
if [ "$unknown" != "$EXP" ]; then
  echo "FAIL: unknown-patterns=$unknown but EXPECT_UNKNOWN=$EXP."
  echo "      An UNKNOWN-PATTERN can never read as green -- it is a typo, or it"
  echo "      belongs to the OTHER corpus.  Measured expectations: 1 on a"
  echo "      surelog csv (2DFunctionArg), 6 on a uhdm2rtlil csv (TypespecExpr,"
  echo "      ClogCast, PartSelect4, EvalFunc*, ParamFile*, Black*)."
  exit 6
fi
if [ "$changed" != 0 ] || [ "$absent" != 0 ]; then
  echo "FAIL: a supplementary canary moved."
  exit 5
fi
echo "PASS: every supplementary canary row is byte-identical to the baseline."
