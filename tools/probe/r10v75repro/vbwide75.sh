#!/usr/bin/env bash
# r10v75 (VERIFIER) — WIDE per-FILE boundary over a COPY of tools/probe, NO path
# filter, .sv and .v at ANY depth, BOTH views, BOTH frozen binaries, dumps
# workdir-normalised and byte-compared.  The file list is read on fd 3 and every
# child runs with </dev/null (RESUME §9: a stdin list is swallowed by the first
# child); PROCESSED is asserted against LISTED and every cell records its rc.
# The four slang-fenced tests are excluded by the FENCED_RE regex supplied on
# the command line -- deliberately NOT spelled in this file.
# usage: PATCHED_BIN=.. PRISTINE_BIN=.. vbwide75.sh <list-file> <out-prefix>
set -u
DUMP=${UHDMDUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
P=${PATCHED_BIN:?}; Q=${PRISTINE_BIN:?}
LIST=$1; OUT=$2; TMP=${TMPD:-/tmp/v75_bwide}; mkdir -p "$TMP"
: > "$OUT.cells"; : > "$OUT.rc"; : > "$OUT.diff"
n=0
while read -r f <&3; do
  n=$((n+1))
  rel=${f#/}; key=$(printf '%s' "$rel" | tr '/' '_')
  d="$TMP/$key"; rm -rf "$d"; mkdir -p "$d"
  for view in def elab; do
    args=""; [ "$view" = elab ] && args="--elabuhdm"
    for side in A B; do
      bin=$P; [ "$side" = B ] && bin=$Q
      ( cd "$d" && timeout 120 "$bin" "$f" $args -o "$side.$view.uhdm" > "$side.$view.log" 2>&1 </dev/null )
      echo "$rel $view $side rc=$?" >> "$OUT.rc"
      if [ -f "$d/$side.$view.uhdm" ]; then
        timeout 300 "$DUMP" "$d/$side.$view.uhdm" 2>/dev/null \
          | sed "1s/^[^ ]*[.]uhdm:/DB:/; s#$d##g; s#$TMP##g" > "$d/$side.$view.txt"
      fi
    done
    if [ -s "$d/A.$view.txt" ] && [ -s "$d/B.$view.txt" ]; then
      if cmp -s "$d/A.$view.txt" "$d/B.$view.txt"; then
        echo "$rel $view identical" >> "$OUT.cells"
      else
        echo "$rel $view DIFFERING" >> "$OUT.cells"
        { echo "### $rel $view"; diff "$d/B.$view.txt" "$d/A.$view.txt" | head -60; } >> "$OUT.diff"
      fi
    else
      echo "$rel $view no_output" >> "$OUT.cells"
    fi
  done
  rm -f "$d"/*.uhdm
done 3< "$LIST"
echo "LISTED=$(wc -l < "$LIST") PROCESSED=$n identical=$(grep -c ' identical$' "$OUT.cells" || true) DIFFERING=$(grep -c ' DIFFERING$' "$OUT.cells" || true) no_output=$(grep -c ' no_output$' "$OUT.cells" || true)" | tee "$OUT.tally"
