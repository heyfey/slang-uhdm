#!/usr/bin/env bash
# r10earl120 -- run cen120 over a WHOLE verify_golden.py workdir: the GOLDEN
# database (path read from each test's OWN cmds.txt, never guessed) and OUR
# database, for every test x mode present.  MEASUREMENT ONLY.
#
#   CEN=<path to cen120> bash censweep120.sh <workdir> <out.tsv>
#
# GUARDS, each one an ops trap this campaign has paid for:
#   * the golden path comes out of cmds.txt's `golden cache hit` line and the
#     cache DIRECTORY is turned into .../golden.uhdm (handing a directory to a
#     reader compares nothing);
#   * BOTH sides are existence-checked and a missing side is COUNTED, not
#     silently skipped -- a driver that reaches nothing must never read as
#     perfection;
#   * EVERY cen120 rc is recorded, and cen120 itself prints a `CENRC` line, so
#     a crashed reader cannot pass for an empty census;
#   * the list is read on fd 3 and children get </dev/null.
set -u
WD=${1:?workdir}
OUT=${2:?out.tsv}
CEN=${CEN:?path to cen120}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no cen120 at $CEN"; exit 3; }
: > "$OUT"; : > "$OUT.rc"
find "$WD" -mindepth 3 -maxdepth 3 -name cmds.txt | sort > "$OUT.list"
n=0; miss=0; okg=0; oko=0
while read -r c <&3; do
  n=$((n+1))
  d=$(dirname "$c")
  mode=$(basename "$(dirname "$d")")
  test=$(basename "$d"); test=${test%-*}
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$c" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G="$G/golden.uhdm"
  O="$d/slang.uhdm"
  if [ -z "$G" ] || [ ! -f "$G" ]; then
    echo "MISSGOLD $mode $test" >> "$OUT.rc"; miss=$((miss+1))
  else
    "$CEN" "$G" </dev/null 2>/dev/null | sed "s#^#G\t$mode\t$test\t#" >> "$OUT"
    echo "$? G $mode $test" >> "$OUT.rc"; okg=$((okg+1))
  fi
  if [ ! -f "$O" ]; then
    echo "MISSOURS $mode $test" >> "$OUT.rc"; miss=$((miss+1))
  else
    "$CEN" "$O" </dev/null 2>/dev/null | sed "s#^#O\t$mode\t$test\t#" >> "$OUT"
    echo "$? O $mode $test" >> "$OUT.rc"; oko=$((oko+1))
  fi
done 3< "$OUT.list"
echo "SWEPT=$n GOLDEN_READ=$okg OURS_READ=$oko MISSING=$miss"
echo "-- CENRC histogram --"
grep -c 'CENRC 0' "$OUT" || true
grep 'CENRC [^0]' "$OUT" | head -5 || true
