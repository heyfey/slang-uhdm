#!/bin/bash
# r10uvm54repro/fams.sh — the FAMILY canaries the per-name canaries.sh does not
# cover: the standing brief protects the `Black*`, `EvalFunc*` and `ParamFile*`
# FAMILIES as blocks, and no per-name list can enumerate them.  Each family's
# whole rows are compared between the committed baseline and a new sweep CSV.
#
#   usage: fams.sh <new.csv> <baseline.csv> [extra-prefix ...]
#
# RUN IT ON THE **SURELOG** CSV.  All three families live only there (measured on
# results/golden_surelog.csv: Black 34 rows, EvalFunc 10, ParamFile 8; on
# results/gate_uhdm2rtlil.csv all three match ZERO rows).  Running it against the
# u2r csv therefore prints EMPTY-FAMILY three times and exits 5 — which is also
# the NEGATIVE CONTROL of the empty-family guard, and it was run.
#
# GUARDS (each one exercised — see README § gates):
#   * a family PREFIX that matches ZERO rows in the baseline is reported as
#     EMPTY-FAMILY and counted, and makes the script exit 5.  Without it a typo'd
#     prefix compares nothing against nothing and prints "IDENTICAL", which is
#     exactly the failure mode that reads as perfection.
#   * both CSVs are existence-checked; a missing file is exit 3, never a verdict.
#   * the comparison is the WHOLE ROW (status AND dump column), taken from the
#     csv text, so a dump-column-only regression cannot slip through.
set -u
NEW=${1:?new csv}
BASE=${2:?baseline csv}
shift 2 || true
FAMS="Black EvalFunc ParamFile ${*:-}"
for f in "$NEW" "$BASE"; do
  [ -f "$f" ] || { echo "FATAL: no csv $f"; exit 3; }
done
rc=0
for p in $FAMS; do
  nb=$(grep -c "^$p" "$BASE" || true)
  nn=$(grep -c "^$p" "$NEW" || true)
  if [ "$nb" -eq 0 ]; then
    echo "EMPTY-FAMILY $p: matches 0 baseline rows — this prefix measures NOTHING"
    rc=5
    continue
  fi
  d=$(diff <(grep "^$p" "$BASE" | sort) <(grep "^$p" "$NEW" | sort) | grep -c '^[<>]' || true)
  if [ "$d" -eq 0 ]; then
    echo "FAMILY $p: baseline rows=$nb new rows=$nn  IDENTICAL"
  else
    echo "FAMILY $p: baseline rows=$nb new rows=$nn  CHANGED lines=$d"
    diff <(grep "^$p" "$BASE" | sort) <(grep "^$p" "$NEW" | sort) | head -20
    rc=1
  fi
done
exit $rc
