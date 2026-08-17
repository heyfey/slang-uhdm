#!/usr/bin/env bash
# r10earl59 VERIFIER — SECTIONED whole-dump path-normalised diff.
#   usage: dumpdiff59.sh <a.dump> <b.dump> <label>
# Normalises array indices and the object ids the dump prints, then reports
# ADDED / REMOVED counts and splits every changed line into ELAB (a path naming
# the top instance) and DEF (a `work@<module>` path with no top prefix).
set -u
A=${1:?a}; B=${2:?b}; L=${3:-diff}
TOP=${TOP_PREFIX:-work@top_earlgrey}
n() { sed -E 's/, id:[0-9]+//g; s/#[0-9]+/#N/g' "$1"; }
diff <(n "$A") <(n "$B") > /tmp/v59_dd_$L.diff
add=$(grep -c '^>' /tmp/v59_dd_$L.diff || true)
rem=$(grep -c '^<' /tmp/v59_dd_$L.diff || true)
echo "$L: ADDED=$add REMOVED=$rem total=$((add+rem))"
echo "  added line SHAPES:"
grep '^>' /tmp/v59_dd_$L.diff | sed -E 's/\(work@[^)]*\)/(PATH)/' | sed 's/^> *//' | sort | uniq -c | sort -rn | head -10
echo "  removed line SHAPES:"
grep '^<' /tmp/v59_dd_$L.diff | sed -E 's/\(work@[^)]*\)/(PATH)/' | sed 's/^< *//' | sort | uniq -c | sort -rn | head -10
echo "  changed lines naming a path: ELAB(top)=$(grep -E '^[<>]' /tmp/v59_dd_$L.diff | grep -c "$TOP" || true) DEF(non-top work@)=$(grep -E '^[<>]' /tmp/v59_dd_$L.diff | grep 'work@' | grep -vc "$TOP" || true)"
echo "  DEF-side changed lines (first 10):"
grep -E '^[<>]' /tmp/v59_dd_$L.diff | grep 'work@' | grep -v "$TOP" | head -10
