#!/usr/bin/env bash
# r10earl89 — the CORPUS census.  Runs dimts89 over EVERY database of a sweep
# workdir AND over the GOLDEN named in that test's OWN cmds.txt (the immutable
# golden-cache path).  IT READS DATABASES AND DISPATCHES NOTHING — no test,
# fenced or otherwise, is ever run by it.  MEASUREMENT ONLY.
#   usage: DIMTS89=.. cen89.sh <sweep-workdir> <out-prefix>
set -u
CEN=${DIMTS89:?set DIMTS89}
WD=$(readlink -f "$1"); OUT="$2"
: > "$OUT.golden"; : > "$OUT.ours"; n=0; ng=0
while IFS= read -r c; do
  d=$(dirname "$c")
  rel=${d#"$WD"/}
  [ -f "$d/slang.uhdm" ] || continue
  "$CEN" "$d/slang.uhdm" 2>/dev/null | sed "s|^RG |RG $rel\|\||" >> "$OUT.ours"
  n=$((n+1))
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[a-f0-9]*' "$c" | head -1)
  [ -n "$g" ] && [ -f "$g/golden.uhdm" ] || continue
  "$CEN" "$g/golden.uhdm" 2>/dev/null | sed "s|^RG |RG $rel\|\||" >> "$OUT.golden"
  ng=$((ng+1))
done < <(find "$WD" -name cmds.txt | sort)
echo "databases=$n goldens=$ng ours_cells=$(wc -l < "$OUT.ours") golden_cells=$(wc -l < "$OUT.golden")"
