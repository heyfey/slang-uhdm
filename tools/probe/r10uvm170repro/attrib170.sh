#!/usr/bin/env bash
# r10uvm170repro/attrib170.sh — MOVER ATTRIBUTION.  MEASUREMENT ONLY.
#
#   attrib170.sh <pristine-workdir> <patched-workdir> <outdir> <row-regex>
#
# For every named row it dumps BOTH databases with `uhdm-dump`, normalises the
# workdir path out (dump paths embed the workdir — RESUME.md §9), and prints
#   * the plain diff line count, and
#   * the ORDER-BLIND (sorted) diff line count.
# Scoreboard/default is a ~50/50 COIN per invocation, so ONLY the order-blind
# figure may be attributed there; a coin shows 0 sorted lines beyond the law's.
# Object IDs shift when a law mints an extra object, so the ID column is
# stripped before the compare and reported separately.
set -u
WA=${1:?pristine wd}; WB=${2:?patched wd}; OUT=${3:?outdir}; ROWS=${4:?row regex}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
mkdir -p "$OUT"
for mode in default testflags; do
  for d in "$WA/$mode"/*/; do
    [ -d "$d" ] || continue
    row=$(basename "$d"); echo "$row" | grep -qE "$ROWS" || continue
    A=$d/slang.uhdm; B=$WB/$mode/$row/slang.uhdm
    [ -f "$A" ] && [ -f "$B" ] || { echo "SKIP $mode/$row"; continue; }
    for s in a b; do
      case $s in a) F=$A; W=$WA;; b) F=$B; W=$WB;; esac
      # `$d` already ends in `/`, so the pristine path carries a DOUBLE slash;
      # collapse it or the header line reads as a diff of its own.
      "$DUMP" "$F" 2>/dev/null | sed "s#$W#WD#g; s#//slang.uhdm#/slang.uhdm#g" \
        > "$OUT/$mode.$row.$s.dmp"
      # the same again with every `id:<n>` stripped — a minted object shifts
      # every later id and would otherwise drown the real lines
      sed 's/id:[0-9]*/id:N/g' "$OUT/$mode.$row.$s.dmp" > "$OUT/$mode.$row.$s.noid"
      LC_ALL=C sort "$OUT/$mode.$row.$s.noid" > "$OUT/$mode.$row.$s.sorted"
    done
    p=$(diff "$OUT/$mode.$row.a.noid" "$OUT/$mode.$row.b.noid" | grep -cE '^[<>]' || true)
    o=$(diff "$OUT/$mode.$row.a.sorted" "$OUT/$mode.$row.b.sorted" | grep -cE '^[<>]' || true)
    printf "%-10s %-24s plain=%-6s order-blind=%s\n" "$mode" "$row" "$p" "$o"
    diff "$OUT/$mode.$row.a.sorted" "$OUT/$mode.$row.b.sorted" |
      grep -E '^[<>]' > "$OUT/$mode.$row.sorteddiff" || true
  done
done
