#!/usr/bin/env bash
# r10uvm192repro/attrib192.sh — ORDER-BLIND ATTRIBUTION of every byte mover.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
# RESUME.md §9: attribute ONLY order-blind — `Scoreboard/default` is a ~50/50
# COIN per invocation, so a raw dump diff there reads as change even when
# nothing moved.  This dumps both databases, NORMALISES the workdir path out
# (dump paths embed it), SORTS both, and diffs — so a pure ORDER flip scores
# zero lines and only real content shows.
#
# It then classifies every changed line: a line belongs to this law when it is
# a `vpiFunction`/`vpiTask` edge or sits under one, i.e. it names a subroutine
# by a CLASS-QUALIFIED `C::m` VpiName or by the bare `m` the law moves off.
# Anything else is printed in full as UNATTRIBUTED and must be zero.
#
#   usage: attrib192.sh <patched workdir> <pristine workdir> <outdir> <rel...>
set -u
PW=${1:?patched workdir}; RW=${2:?pristine workdir}; OUT=${3:?outdir}
shift 3
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
mkdir -p "$OUT" || exit 3
tot=0; una=0
for rel in "$@"; do
  p="$PW/$rel"; r="$RW/$rel"
  key=$(echo "$rel" | tr '/' '_')
  if [ ! -f "$p" ] || [ ! -f "$r" ]; then echo "MISSING $rel"; continue; fi
  "$DUMP" "$p" 2>/dev/null | sed "s|$PW||g" | sort > "$OUT/$key.pat"
  "$DUMP" "$r" 2>/dev/null | sed "s|$RW||g" | sort > "$OUT/$key.pri"
  add=$(comm -13 "$OUT/$key.pri" "$OUT/$key.pat" | wc -l)
  rem=$(comm -23 "$OUT/$key.pri" "$OUT/$key.pat" | wc -l)
  comm -3 "$OUT/$key.pri" "$OUT/$key.pat" > "$OUT/$key.diff"
  # Lines this law can produce: a subroutine face or an edge naming one.
  u=$(grep -avE 'vpiFunction|vpiTask|^[[:space:]]*\\_(function|task): ' \
        "$OUT/$key.diff" | wc -l)
  echo "$rel  ADDED=$add REMOVED=$rem SORTED-DIFF-LINES=$((add+rem)) UNATTRIBUTED=$u"
  tot=$((tot+add+rem)); una=$((una+u))
  [ "$u" -gt 0 ] && { echo "---- UNATTRIBUTED lines in $rel:"; grep -avE 'vpiFunction|vpiTask|^[[:space:]]*\\_(function|task): ' "$OUT/$key.diff" | head -40; }
done
echo "-- TOTAL sorted-diff lines=$tot UNATTRIBUTED=$una"
