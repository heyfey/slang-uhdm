#!/usr/bin/env bash
# r10v104 — ORDER-BLIND per-database attribution of a byteverify mover.
# The dumps are path-normalised and SORTED before the diff, because
# Scoreboard/default is a ~50/50 `vpiTaskFunc` ordering coin and an unsorted
# diff would attribute the coin to the law.  Reports total moved lines and how
# many of them are NOT string-valued (`STRING:` / `vpiDecompile:`); a law that
# only rewrites string text must show non_string_lines=0.
#
#   usage: PRISWD=<pristine workdir> PATWD=<patched workdir> ATTRWD=<scratch> \
#          attr104.sh <mode>/<db-dir> ...
set -u
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
PRISWD=${PRISWD:?}; PATWD=${PATWD:?}; A=${ATTRWD:?}
mkdir -p "$A"
for db in "$@"; do
  tag=$(echo "$db" | tr '/' '_')
  # A PARTIAL dump reads like a result: always write to a temp and rename.
  [ -f "$A/$tag.pris" ] || { $DUMP "$PRISWD/$db/slang.uhdm" 2>/dev/null </dev/null | sed -e "s|$PRISWD/||g" | sort > "$A/$tag.pris.tmp" && mv "$A/$tag.pris.tmp" "$A/$tag.pris"; }
  [ -f "$A/$tag.pat"  ] || { $DUMP "$PATWD/$db/slang.uhdm"  2>/dev/null </dev/null | sed -e "s|$PATWD/||g"  | sort > "$A/$tag.pat.tmp"  && mv "$A/$tag.pat.tmp"  "$A/$tag.pat"; }
  n=$(diff "$A/$tag.pris" "$A/$tag.pat" | grep -cE '^[<>]'; true)
  ns=$(diff "$A/$tag.pris" "$A/$tag.pat" | grep -E '^[<>]' | grep -vcE 'STRING:|vpiDecompile:'; true)
  echo "$db  sorted_diff_lines=$n  non_string_lines=$ns"
done
