#!/usr/bin/env bash
# r10uvm196repro/grid196.sh — the ARM DRIVER.  MEASUREMENT ONLY; the official
# `uhdm-cmp` is the sole judge.  Descended from r10uvm192repro/grid192.sh, with
# one change: an arm here is a LIST OF FILES (a file-scope import only reaches
# the modules written in its own file, so the same-buffer term cannot be tested
# from a single source).
#
#   IMP=<ct196imp> CEN=<ct196cen> grid196.sh <name> <binA:pristine> <binB:patched> <workdir> <file>...
#
# Builds ONE REAL SURELOG GOLDEN and BOTH binaries' databases in BOTH views,
# echoes every command WITH ITS BINARY PATH into <workdir>/cmds.txt and records
# every rc — an rc=139 SEGFAULT must never read as a result (RESUME.md §9).
# A missing database is NAMED, never silently skipped.
set -u
NAME=$1; A=$2; B=$3; W=$4; shift 4
FILES=()
for f in "$@"; do FILES+=("$(readlink -f "$f")"); done
IMP=${IMP:?set IMP to the built ct196imp}
CEN=${CEN:?set CEN to the built ct196cen}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
mkdir -p "$W"; : > "$W/cmds.txt"; : > "$W/md5.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "${FILES[@]}" )
  run "$A" "${FILES[@]}" $EF -o "$W/a_$v.uhdm"
  run "$B" "${FILES[@]}" $EF -o "$W/b_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  for pair in "$G:imp.g.$v.txt" "$W/a_$v.uhdm:imp.a.$v.txt" "$W/b_$v.uhdm:imp.b.$v.txt"; do
    f=${pair%%:*}; out=${pair#*:}
    if [ -f "$f" ]; then
      "$IMP" "$f" "$v" > "$W/$out" 2>>"$W/imp.err"
      echo "imp rc=$? $f rows=$(wc -l < "$W/$out")" >> "$W/cmds.txt"
    else : > "$W/$out"; echo "imp MISSING $f" >> "$W/cmds.txt"; fi
  done
  for s in a b; do
    if [ -f "$G" ] && [ -f "$W/${s}_$v.uhdm" ]; then
      "$CEN" --cen "$G" "$W/${s}_$v.uhdm" "$NAME/$v/$s" > "$W/cen.$s.$v.txt" 2>&1
      echo "cen rc=$? $s $v" >> "$W/cmds.txt"
      "$CMP" "$G" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
      echo "cmp rc=$? $s $v lines=$(wc -l < "$W/cmp.$s.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$s.$v.txt" || true)" >> "$W/cmds.txt"
    else
      echo "cen/cmp MISSING $s $v" >> "$W/cmds.txt"
      : > "$W/cen.$s.$v.txt"
    fi
  done
  for s in a b; do
    [ -f "$W/${s}_$v.uhdm" ] && md5sum "$W/${s}_$v.uhdm" >> "$W/md5.txt"
  done
done
echo "=== $NAME ==="
echo "--- nonzero rcs:"; grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0 ' ; true
echo "--- cmp:"; grep -E '^cmp ' "$W/cmds.txt"; true
echo "--- census summary (LHS golden, RHS ours):"
grep -h '^CENSUM' "$W"/cen.*.txt; true
echo "--- byte identity pristine vs patched (per view):"
for v in def elab; do
  if [ -f "$W/a_$v.uhdm" ] && [ -f "$W/b_$v.uhdm" ]; then
    if cmp -s "$W/a_$v.uhdm" "$W/b_$v.uhdm"; then echo "$v IDENTICAL"; else echo "$v DIFFER"; fi
  fi
done
