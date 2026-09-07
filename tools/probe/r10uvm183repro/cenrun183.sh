#!/usr/bin/env bash
# r10uvm183 — the corpus FOREACH census over a sweep workdir pair.
# MEASUREMENT ONLY.  LHS is ALWAYS golden, RHS ALWAYS ours.
#
#   cenrun183.sh <pristine-wd> <patched-wd|-> <outdir> '<row regex>'
#
# For every row-mode matching the regex it dumps `ct183cen --fe` for the
# GOLDEN database (read from the row's OWN cmds.txt, so no golden path is
# guessed), for the PRISTINE database and, when a patched workdir is given,
# for the PATCHED one.  Every rc is recorded.
set -u
PRIS=${1:?pristine workdir}
PAT=${2:?patched workdir or -}
OUT=${3:?outdir}
RE=${4:-.}
CEN=${CT183CEN:?set CT183CEN to the built ct183cen}
mkdir -p "$OUT"
: > "$OUT/rows.txt"
: > "$OUT/rc.txt"
n=0
for mode in default testflags; do
  [ -d "$PRIS/$mode" ] || continue
  for d in "$PRIS/$mode"/*/; do
    row=$(basename "$d")
    name=${row%-*}
    echo "$name" | grep -qE "$RE" || continue
    [ -f "$d/slang.uhdm" ] || { echo "$mode/$name NO_OURS" >> "$OUT/rc.txt"; continue; }
    g=$(tr ' ' '\n' < "$d/cmds.txt" | grep -o '/home/[^ )]*slang-uhdm-goldens/[0-9a-f]*' | head -1)
    [ -n "$g" ] && [ -f "$g/golden.uhdm" ] || { echo "$mode/$name NO_GOLDEN" >> "$OUT/rc.txt"; continue; }
    "$CEN" "$g/golden.uhdm" --fe > "$OUT/$mode.$name.golden.tsv" 2>&1; echo "$mode/$name golden rc=$?" >> "$OUT/rc.txt"
    "$CEN" "$d/slang.uhdm"  --fe > "$OUT/$mode.$name.pris.tsv"   2>&1; echo "$mode/$name pris rc=$?" >> "$OUT/rc.txt"
    if [ "$PAT" != "-" ] && [ -f "$PAT/$mode/$row/slang.uhdm" ]; then
      "$CEN" "$PAT/$mode/$row/slang.uhdm" --fe > "$OUT/$mode.$name.pat.tsv" 2>&1
      echo "$mode/$name pat rc=$?" >> "$OUT/rc.txt"
    fi
    echo "$mode $name" >> "$OUT/rows.txt"
    n=$((n+1))
  done
done
echo "ROWS=$n"
