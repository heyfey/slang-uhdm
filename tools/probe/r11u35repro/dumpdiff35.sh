#!/bin/bash
# r11u35 — whole-dump diff size per row, with the range-bound census beside it.
# usage: dd.sh <workdir-root> <outdir>
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
WD=${1:?}; OUT=${2:?}; mkdir -p $OUT
for d in $(find "$WD" -name slang.uhdm | sort); do
  dir=$(dirname "$d"); nm=$(basename "$dir"); mode=$(basename $(dirname "$dir"))
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$dir/cmds.txt" | head -1)
  [ -z "$g" ] && { echo "NOGOLD $nm/$mode"; continue; }
  $DUMP $g/golden.uhdm > $OUT/$nm.$mode.gold.dump 2>&1
  $DUMP "$d"          > $OUT/$nm.$mode.ours.dump 2>&1
  gl=$(wc -l < $OUT/$nm.$mode.gold.dump); dl=$(diff $OUT/$nm.$mode.gold.dump $OUT/$nm.$mode.ours.dump | grep -c '^[<>]' ; true)
  echo "$nm [$mode] goldlines=$gl difflines=$dl"
done
