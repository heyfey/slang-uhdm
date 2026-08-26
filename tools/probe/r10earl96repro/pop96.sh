#!/usr/bin/env bash
# r10earl96 -- THE POPULATION SCAN (denominator).  MEASUREMENT ONLY.  For every
# database of a sweep, print every GOLDEN alias-chain row whose path reaches an
# array element through a param_assign Rhs (the law's population) and every one
# that reaches it through the Lhs / the parameter listing (the law's boundary),
# so a QUALIFIED golden alias target anywhere in either set is visible.
set -u
CEN=${CEN96:?}; W=$(readlink -f "$1"); OUT=$2
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT"
while IFS= read -r db; do
  d=$(dirname "$db"); tag=${d#$W/}
  gc=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$d/cmds.txt" 2>/dev/null)
  [ -n "$gc" ] && [ -f "$gc/golden.uhdm" ] || continue
  "$CEN" "$gc/golden.uhdm" </dev/null 2>/dev/null | grep '^AL' | grep '>e>r' | sed "s#^#G\t$tag\t#" >> "$OUT"
  "$CEN" "$db"             </dev/null 2>/dev/null | grep '^AL' | grep '>e>r' | sed "s#^#O\t$tag\t#" >> "$OUT"
done < <(find "$W" -name 'slang.uhdm' | sort)
echo "-- rows=$(wc -l < "$OUT")"
