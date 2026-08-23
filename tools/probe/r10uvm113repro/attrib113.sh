#!/bin/bash
# r10uvm113 attrib113.sh — ORDER-BLIND mover attribution.
#
# Scoreboard/default is a ~50/50 COIN per invocation (svunit_pkg vpiTaskFunc
# listing order; macro-buffer SourceLocation ordering under slang's parallel
# parse), so a raw diff of two dumps is unreadable.  Both dumps are
# path-normalised (dump text embeds the workdir), SORTED, and diffed; what
# survives is what the pass actually moved.
#
#   usage: attrib113.sh <patched-workdir> <pristine-workdir> <outdir> [names...]
set -u
PW=${1:?patched workdir}; QW=${2:?pristine workdir}; OUT=${3:?outdir}; shift 3
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT" || exit 1
for n in "$@"; do
  for m in default testflags; do
    for d in "$PW/$m/$n"-*/; do
      [ -d "$d" ] || continue
      q=${d/$PW/$QW}
      [ -f "$d/slang.uhdm" ] && [ -f "$q/slang.uhdm" ] || { echo "SKIP-NOFILE $n/$m"; continue; }
      "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed "s#$PW##g; s#$QW##g" | LC_ALL=C sort > "$OUT/$n.$m.pat"
      "$DUMP" "$q/slang.uhdm" 2>/dev/null | sed "s#$PW##g; s#$QW##g" | LC_ALL=C sort > "$OUT/$n.$m.pris"
      diff "$OUT/$n.$m.pris" "$OUT/$n.$m.pat" > "$OUT/$n.$m.diff"
      a=$(grep -c '^<' "$OUT/$n.$m.diff"; true); b=$(grep -c '^>' "$OUT/$n.$m.diff"; true)
      echo "== $n/$m  removed=$a added=$b"
      sort "$OUT/$n.$m.diff" | grep -E '^[<>]' | sed 's/[0-9]\+/N/g' | sort | uniq -c | sort -rn | head -12
    done
  done
done
