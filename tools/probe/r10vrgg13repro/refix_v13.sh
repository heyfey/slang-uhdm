#!/usr/bin/env bash
# vrgg13 — re-read ONLY the FIX side of the already-built arm grid (golden and
# base sides are immutable; they are NOT rebuilt).
set -u
AD=${1:?arms}; OUT=${2:?out}
CEN=/tmp/vrgg13_acensus
FIX=/tmp/vrgg13_bin/slang-uhdm-fix
: > "$OUT/fix.cen"; : > "$OUT/fixE.cen"; : > "$OUT/fixsummary.txt"
n=0; moved=0
for d in "$AD"/*/; do
  c=$(basename "$d")
  [ -f "$d/golden.uhdm" ] || continue
  ( cd "$d" && rm -rf slpp_all
    "$FIX" top.sv --single-unit -o fix.uhdm > f.log 2>&1; echo $? > fix.rc
    "$FIX" top.sv --single-unit --elabuhdm -o fixE.uhdm > fE.log 2>&1; echo $? > fixE.rc
    rm -rf slpp_all )
  [ -f "$d/fix.uhdm" ] || { echo "NODB-FIX $c" >> "$OUT/fixsummary.txt"; continue; }
  fl=$($HOME/.local/bin/uhdm-cmp "$d/golden.uhdm" "$d/fix.uhdm" 2>&1 | tee "$d/cmp_fix.txt" | wc -l)
  bl=$(wc -l < "$d/cmp_base.txt" 2>/dev/null || echo -1)
  pl=$(wc -l < "$d/cmp_pat.txt" 2>/dev/null || echo -1)
  tag=""; [ "$fl" != "$bl" ] && { tag="  <<< FIXDELTA base=$bl pat=$pl fix=$fl"; moved=$((moved+1)); }
  echo "$c base=$bl pat=$pl fix=$fl$tag" >> "$OUT/fixsummary.txt"
  "$CEN" "$d/fix.uhdm"  2>/dev/null | sed "s#^#$c\t#" >> "$OUT/fix.cen"
  [ -f "$d/goldenE.uhdm" ] && [ -f "$d/fixE.uhdm" ] && "$CEN" "$d/fixE.uhdm" 2>/dev/null | sed "s#^#$c\t#" >> "$OUT/fixE.cen"
  n=$((n+1))
done
echo "-- cells=$n movers-vs-base=$moved" >> "$OUT/fixsummary.txt"
tail -1 "$OUT/fixsummary.txt"
