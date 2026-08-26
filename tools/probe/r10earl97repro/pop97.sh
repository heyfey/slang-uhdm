#!/usr/bin/env bash
# r10earl97 -- THE DENOMINATOR.  Every GOLDEN cell of the law's shape -- an
# `int_typespec` owned by a cast OPERATION and carrying a Cast_to_expr (the
# object Surelog builds by REUSING the cast target parameter's DECLARATION
# typespec) -- over every database of a sweep, with its VpiSigned payload.
# Also tallies the whole integer-kind VpiSigned population by kind x role.
#   usage: pop97.sh <sweep-workdir> <out-prefix>    env: CEN97
set -u
CEN=${CEN97:?}; W=$(readlink -f "$1"); OUT=$2
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT.law"; : > "$OUT.allkinds"
T=$(mktemp -d /tmp/r10earl97_pop.XXXXXX); n=0
while IFS= read -r db; do
  d=$(dirname "$db"); tag=${d#$W/}
  gc=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$d/cmds.txt" 2>/dev/null)
  [ -n "$gc" ] && [ -f "$gc/golden.uhdm" ] || continue
  "$CEN" "$gc/golden.uhdm" </dev/null 2>/dev/null > "$T/g" || continue
  grep -E '^int\|[^|]*\|[^|]*\|cast\|' "$T/g" | grep '|1|0	' | sed "s#^#$tag\t#" >> "$OUT.law"
  awk -F'|' '{split($0,a,"\t"); print $1"\t"$4"\t"a[2]}' "$T/g" | sort | uniq -c >> "$OUT.allkinds"
  n=$((n+1))
done < <(find "$W" -name 'slang.uhdm' | sort)
rm -rf "$T"
echo "-- goldens=$n  law-shape rows=$(wc -l < "$OUT.law")"
