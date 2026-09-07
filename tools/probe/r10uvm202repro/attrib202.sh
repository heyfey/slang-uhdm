#!/usr/bin/env bash
# r10uvm202 — MOVER ATTRIBUTION.  MEASUREMENT ONLY.
#   attrib202.sh <pristine-wd> <patched-wd> <outdir> '<row regex>'
# For every matching row it dumps both databases with `uhdm-dump`, NORMALISES
# the workdir path out (dump paths embed the workdir) and STRIPS `id:` numbers
# (a mint shifts every later id), then diffs PLAIN and ORDER-BLIND (sorted) —
# Scoreboard/default is a ~50/50 coin and can only be read order-blind
# (RESUME.md §9).
set -u
PRIS=${1:?} PAT=${2:?} OUT=${3:?} RE=${4:-.}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
mkdir -p "$OUT"
: > "$OUT/summary.txt"
for mode in default testflags; do
  [ -d "$PRIS/$mode" ] || continue
  for d in "$PRIS/$mode"/*/; do
    row=$(basename "$d"); name=${row%-*}
    echo "$name" | grep -qE "$RE" || continue
    p="$d/slang.uhdm"; q="$PAT/$mode/$row/slang.uhdm"
    [ -f "$p" ] && [ -f "$q" ] || continue
    cmp -s "$p" "$q" && continue
    norm() { sed -e "s#$PRIS##g" -e "s#$PAT##g" -e 's/, id:[0-9]*//g' -e 's/id:[0-9]*//g'; }
    "$DUMP" "$p" 2>/dev/null | norm > "$OUT/$mode.$name.pris.dmp"
    "$DUMP" "$q" 2>/dev/null | norm > "$OUT/$mode.$name.pat.dmp"
    diff "$OUT/$mode.$name.pris.dmp" "$OUT/$mode.$name.pat.dmp" > "$OUT/$mode.$name.plain.diff"
    sort "$OUT/$mode.$name.pris.dmp" > "$OUT/$mode.$name.pris.srt"
    sort "$OUT/$mode.$name.pat.dmp"  > "$OUT/$mode.$name.pat.srt"
    diff "$OUT/$mode.$name.pris.srt" "$OUT/$mode.$name.pat.srt" > "$OUT/$mode.$name.blind.diff"
    printf '%-10s %-14s plain=%-6s order-blind=%-6s\n' "$mode" "$name" \
      "$(grep -c '^[<>]' "$OUT/$mode.$name.plain.diff" || true)" \
      "$(grep -c '^[<>]' "$OUT/$mode.$name.blind.diff" || true)" >> "$OUT/summary.txt"
    echo "---- $mode $name ORDER-BLIND diff, by line shape:" >> "$OUT/summary.txt"
    grep '^[<>]' "$OUT/$mode.$name.blind.diff" | sed 's/[0-9]\+/N/g' | sort | uniq -c | sort -rn >> "$OUT/summary.txt"
  done
done
cat "$OUT/summary.txt"
