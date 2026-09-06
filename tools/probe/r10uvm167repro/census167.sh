#!/usr/bin/env bash
# r10uvm167repro/census167.sh — the FAMILY census over named verify_golden rows.
# MEASUREMENT ONLY.
#
#   CEN=<ct167cen> SCORE=<score167.py> census167.sh <pris wd> <pat wd> <outdir> <name>...
#
# For every named row in BOTH modes: censuses GOLDEN (read out of the row's own
# cmds.txt, rowheads.sh's guard), the PRISTINE database and the PATCHED one with
# the SAME tool and the SAME tag, and scores the triple.  The RUN (row+mode) is
# part of every tag, so no two databases are ever merged into one multiset.
set -u
PW=${1:?pristine workdir}; QW=${2:?patched workdir}; OUT=${3:?outdir}
shift 3
CEN=${CEN:?set CEN}; SCORE=${SCORE:?set SCORE}
mkdir -p "$OUT"
: > "$OUT/rows.txt"
for n in "$@"; do
  for mode in default testflags; do
    for d in "$PW/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      r=$(basename "$d")
      P=$d/slang.uhdm
      Q=$QW/$mode/$r/slang.uhdm
      G=""
      [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$P" ] || [ ! -f "$Q" ]; then
        echo "SKIP-NOFILE $mode/$r g=${G:-none}" >> "$OUT/rows.txt"; continue
      fi
      T="$mode.$r"
      "$CEN" "$G" "G.$T" --noobj > "$OUT/$T.g.txt" 2>/dev/null
      "$CEN" "$P" "O.$T" --noobj > "$OUT/$T.a.txt" 2>/dev/null
      "$CEN" "$Q" "O.$T" --noobj > "$OUT/$T.b.txt" 2>/dev/null
      echo "ROW $mode/$r" >> "$OUT/rows.txt"
    done
  done
done
cat "$OUT"/*.g.txt > "$OUT/all.g.txt"; cat "$OUT"/*.a.txt > "$OUT/all.a.txt"
cat "$OUT"/*.b.txt > "$OUT/all.b.txt"
echo "== rows =="; cat "$OUT/rows.txt"
for f in CALL ARG; do
  echo "== family $f =="
  python3 "$SCORE" "$OUT/all.g.txt" "$OUT/all.a.txt" "$OUT/all.b.txt" --fam $f --list \
    | grep -Ev '^  STILL '
done
