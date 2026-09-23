#!/bin/bash
# dist110.sh <grid-out-root> <before-tag> <after-tag>
# For every arm whose <after>.uhdm differs from <before>.uhdm: the official
# uhdm-cmp line/head counts (LHS golden) and the ORDER-BLIND whole-dump
# distance to golden (uhdm-dump, file paths normalised, sorted, diff lines
# counted), before -> after.
ROOT=${1:?root}; B=${2:?before}; A=${3:?after}
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
dist() { diff <("$DUMP" "$1" 2>/dev/null | sed 's#file:[^,]*,##; s#id:[0-9]*##g' | sort) \
              <("$DUMP" "$2" 2>/dev/null | sed 's#file:[^,]*,##; s#id:[0-9]*##g' | sort) | grep -c '^[<>]'; true; }
while read -r g <&3; do
  d=$(dirname "$g"); arm=${d#$ROOT/}
  [ -f "$d/$B.uhdm" ] && [ -f "$d/$A.uhdm" ] || continue
  cmp -s "$d/$B.uhdm" "$d/$A.uhdm" && continue
  echo "$arm cmp $(wc -l < "$d/$B.cmp")/$(grep -c '^LHS:' "$d/$B.cmp"; true) -> $(wc -l < "$d/$A.cmp")/$(grep -c '^LHS:' "$d/$A.cmp"; true) dist $(dist "$g" "$d/$B.uhdm") -> $(dist "$g" "$d/$A.uhdm")"
done 3< <(find "$ROOT" -name gold.uhdm | sort)
