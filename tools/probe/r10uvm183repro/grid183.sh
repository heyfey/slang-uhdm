#!/usr/bin/env bash
# r10uvm183repro/grid183.sh — the arm driver.  MEASUREMENT ONLY; the official
# `uhdm-cmp` is the sole judge.
#   CT183CEN=<ct183cen> grid183.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
# Builds ONE REAL SURELOG GOLDEN and BOTH binaries' databases in BOTH views,
# echoing every command WITH ITS BINARY PATH into <workdir>/cmds.txt and
# recording every rc — an rc=139 SEGFAULT must never read as a result
# (RESUME.md §9).  Descended from r10uvm181repro/grid181.sh.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
CEN=${CT183CEN:?set CT183CEN to the built ct183cen}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:cen.g.$v.txt" "a_$v.uhdm:cen.a.$v.txt" "b_$v.uhdm:cen.b.$v.txt"; do
    f=${pair%%:*}; out=${pair#*:}
    if [ -f "$W/$f" ]; then
      "$CEN" "$W/$f" --fe > "$W/$out" 2>>"$W/cen.err"
      echo "cen rc=$? $f rows=$(wc -l < "$W/$out")" >> "$W/cmds.txt"
    else : > "$W/$out"; echo "cen MISSING $f" >> "$W/cmds.txt"; fi
  done
  for s in a b; do
    if [ -f "$W/g_$v/slpp_all/surelog.uhdm" ] && [ -f "$W/${s}_$v.uhdm" ]; then
      "$CMP" "$W/g_$v/slpp_all/surelog.uhdm" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
      echo "cmp rc=$? $s $v lines=$(wc -l < "$W/cmp.$s.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$s.$v.txt")" >> "$W/cmds.txt"
    else
      echo "cmp MISSING $s $v" >> "$W/cmds.txt"
    fi
  done
  for s in a b; do
    [ -f "$W/${s}_$v.uhdm" ] && md5sum "$W/${s}_$v.uhdm" >> "$W/md5.txt"
  done
done
echo "--- rcs:"; grep '^rc=' "$W/cmds.txt" | sort | uniq -c
echo "--- nonzero rcs:"; grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0 ' ; true
echo "--- cmp:"; grep '^cmp ' "$W/cmds.txt"; true
echo "--- byte identity a vs b (per view):"
for v in def elab; do
  if [ -f "$W/a_$v.uhdm" ] && [ -f "$W/b_$v.uhdm" ]; then
    if cmp -s "$W/a_$v.uhdm" "$W/b_$v.uhdm"; then echo "$v IDENTICAL"; else echo "$v DIFFER"; fi
  fi
done
