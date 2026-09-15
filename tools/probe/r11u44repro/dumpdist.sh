#!/bin/bash
# r11u44repro/dumpdist.sh — the ORDER-BLIND WHOLE-DUMP DISTANCE of a row.
#
# The cmp head is one object.  A row can carry one head and a thousand wrong
# lines, or one head and three.  This measures the second number, so a
# near-conversion row is visible in the triage table beside its face.
#
#   distance = |lines golden has and we do not| + |lines we have and golden
#              does not|, as a MULTISET difference of the two uhdm-dump
#              renderings, after blinding what no generated Compare reads and
#              what is not a fact about the database:
#
#     * `id:N`        -> id:#        (arena serial numbers, per-build)
#     * absolute paths-> basename    (DUMP PATHS EMBED THE WORKDIR — a raw diff
#                                     of two dumps from different workdirs
#                                     reports every line that names a file)
#
#   Sorted, so the reading is ORDER-BLIND: the campaign's coin families flip
#   whole vectors' ORDER per invocation, and an ordered diff would score that
#   as thousands of moved lines.  `comm` over two SORTED files with duplicates
#   kept is a MULTISET difference — a line golden has twice and we have once
#   counts once, which `sort -u` would silently forgive.
#
#   GUARDS:
#     * the dump is re-read and must be BYTE-STABLE before it is counted
#       (a partially written dump reads like a result).  Unstable/timed-out
#       rows print PARTIAL and are NOT given a number.
#     * both sides are existence-checked; a missing side prints SKIP-NOFILE.
#     * the golden path is read out of the workdir's own cmds.txt.
#
#   usage: dumpdist.sh <workdir> <mode> <outdir> <name> [<name> ...]
#   env:   UHDM_DUMP (default ~/git-repos/UHDM/build/bin/uhdm-dump)
#          BUDGET    per-dump timeout in seconds (default 180)
set -u
WD=${1:?workdir}; MODE=${2:?mode}; OUT=${3:?outdir}; shift 3
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
BUDGET=${BUDGET:-180}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
mkdir -p "$OUT" || exit 1

norm() {  # blind ids and absolute paths; the workdir is embedded in every dump
  sed -E 's/id:[0-9]+/id:#/g; s#(/[A-Za-z0-9_.+-]+)+/([A-Za-z0-9_.+-]+)#\2#g'
}

printf "%-32s %-9s %9s %9s %9s %s\n" TEST MODE GOLD_ONLY OURS_ONLY DISTANCE NOTE
for n in "$@"; do
  for d in "$WD/$MODE/$n"-*/; do
    [ -d "$d" ] || continue
    C=$d/cmds.txt; G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    O=$d/slang.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      printf "%-32s %-9s %9s %9s %9s %s\n" "$n" "$MODE" - - - "SKIP-NOFILE"; continue
    fi
    ok=1
    for side in g o; do
      [ $side = g ] && SRC=$G || SRC=$O
      timeout "$BUDGET" "$DUMP" "$SRC" > "$OUT/$n.$MODE.$side.1" 2>/dev/null || ok=0
      timeout "$BUDGET" "$DUMP" "$SRC" > "$OUT/$n.$MODE.$side.2" 2>/dev/null || ok=0
      cmp -s "$OUT/$n.$MODE.$side.1" "$OUT/$n.$MODE.$side.2" || ok=0
    done
    if [ "$ok" -ne 1 ]; then
      printf "%-32s %-9s %9s %9s %9s %s\n" "$n" "$MODE" - - - "PARTIAL/UNSTABLE(budget=${BUDGET}s)"
      rm -f "$OUT/$n.$MODE".[go].[12]; continue
    fi
    norm < "$OUT/$n.$MODE.g.1" | sort > "$OUT/$n.$MODE.g.srt"
    norm < "$OUT/$n.$MODE.o.1" | sort > "$OUT/$n.$MODE.o.srt"
    rm -f "$OUT/$n.$MODE".[go].[12]
    go=$(comm -23 "$OUT/$n.$MODE.g.srt" "$OUT/$n.$MODE.o.srt" | grep -c . || true)
    oo=$(comm -13 "$OUT/$n.$MODE.g.srt" "$OUT/$n.$MODE.o.srt" | grep -c . || true)
    comm -23 "$OUT/$n.$MODE.g.srt" "$OUT/$n.$MODE.o.srt" | sed 's/^/G /' >  "$OUT/$n.$MODE.diff"
    comm -13 "$OUT/$n.$MODE.g.srt" "$OUT/$n.$MODE.o.srt" | sed 's/^/O /' >> "$OUT/$n.$MODE.diff"
    printf "%-32s %-9s %9s %9s %9s %s\n" "$n" "$MODE" "$go" "$oo" "$((go+oo))" \
      "golden=$(wc -l < "$OUT/$n.$MODE.g.srt") ours=$(wc -l < "$OUT/$n.$MODE.o.srt")"
  done
done
