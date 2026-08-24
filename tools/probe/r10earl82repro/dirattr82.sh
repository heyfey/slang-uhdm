#!/usr/bin/env bash
# r10earl82 — IS A PER-DIRECTORY BOUNDARY DIFF EVEN COMPARABLE?  A directory
# whose dump differs between two runs of the SAME binary cannot be evidence
# about the other binary (earl81's residue R6, re-proved per pass).
#   usage: BIN=.. dirattr82.sh <dir> <view> <outdir>
set -u
BIN=${BIN:?}; DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
DIR=$(readlink -f "$1"); VIEW=${2:-plain}; OUT=$(readlink -f "$3")
case $VIEW in elab) FLAGS=--elabuhdm;; *) FLAGS="";; esac
mkdir -p "$OUT"
for r in 1 2; do
  d="$OUT/run$r"; rm -rf "$d"; mkdir -p "$d"; cp "$DIR"/*.sv "$d/" 2>/dev/null
  ( cd "$d" && "$BIN" $FLAGS *.sv -o slang.uhdm >slang.log 2>&1 </dev/null )
  [ -f "$d/slang.uhdm" ] &&
    "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' | sed "s#$d#WD#g" > "$d/o.norm"
done
if cmp -s "$OUT/run1/o.norm" "$OUT/run2/o.norm"; then
  echo "$(basename "$DIR") $VIEW  SELF-STABLE"
else
  echo "$(basename "$DIR") $VIEW  SELF-UNSTABLE (same binary, two runs, two dumps)"
fi
