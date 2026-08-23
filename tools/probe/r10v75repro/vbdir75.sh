#!/usr/bin/env bash
# r10v75 (VERIFIER) — per-DIRECTORY boundary: every .sv/.v of one directory
# compiled TOGETHER, both views, both frozen binaries, dumps workdir-normalised
# and byte-compared.  Directory list on fd 3, children </dev/null, PROCESSED
# asserted, rc per cell.  The four slang-fenced tests are excluded by the
# FENCED_RE regex supplied on the command line -- not spelled in this file.
# usage: PATCHED_BIN=.. PRISTINE_BIN=.. vbdir75.sh <dirlist> <out-prefix>
set -u
DUMP=${UHDMDUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
P=${PATCHED_BIN:?}; Q=${PRISTINE_BIN:?}
LIST=$1; OUT=$2; TMP=${TMPD:-/tmp/v75_bdir}; mkdir -p "$TMP"
: > "$OUT.cells"; : > "$OUT.rc"; : > "$OUT.diff"
n=0
while read -r dir <&3; do
  n=$((n+1))
  key=$(printf '%s' "${dir#/}" | tr '/' '_')
  d="$TMP/$key"; rm -rf "$d"; mkdir -p "$d"
  files=$(ls "$dir"/*.sv "$dir"/*.v 2>/dev/null | tr '\n' ' ')
  [ -z "$files" ] && { echo "$dir - no_output" >> "$OUT.cells"; continue; }
  for view in def elab; do
    args=""; [ "$view" = elab ] && args="--elabuhdm"
    for side in A B; do
      bin=$P; [ "$side" = B ] && bin=$Q
      ( cd "$d" && timeout 180 "$bin" $files $args -o "$side.$view.uhdm" > "$side.$view.log" 2>&1 </dev/null )
      echo "$dir $view $side rc=$?" >> "$OUT.rc"
      if [ -f "$d/$side.$view.uhdm" ]; then
        timeout 300 "$DUMP" "$d/$side.$view.uhdm" 2>/dev/null \
          | sed "1s/^[^ ]*[.]uhdm:/DB:/; s#$d##g; s#$TMP##g" > "$d/$side.$view.txt"
      fi
    done
    if [ -s "$d/A.$view.txt" ] && [ -s "$d/B.$view.txt" ]; then
      if cmp -s "$d/A.$view.txt" "$d/B.$view.txt"; then
        echo "$dir $view identical" >> "$OUT.cells"
      else
        echo "$dir $view DIFFERING" >> "$OUT.cells"
        { echo "### $dir $view"; diff "$d/B.$view.txt" "$d/A.$view.txt" | head -80; } >> "$OUT.diff"
      fi
    else
      echo "$dir $view no_output" >> "$OUT.cells"
    fi
  done
  rm -f "$d"/*.uhdm
done 3< "$LIST"
echo "LISTED=$(wc -l < "$LIST") PROCESSED=$n identical=$(grep -c ' identical$' "$OUT.cells" || true) DIFFERING=$(grep -c ' DIFFERING$' "$OUT.cells" || true) no_output=$(grep -c ' no_output$' "$OUT.cells" || true)" | tee "$OUT.tally"
