#!/usr/bin/env bash
# r10uvm204repro/grid204.sh — the arm driver (r10uvm202repro/grid202.sh form).
# MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
#
#   CEN=<ct204cen> grid204.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
#
# ONE REAL SURELOG GOLDEN and BOTH binaries' databases, in BOTH views, with
# every command AND ITS BINARY PATH echoed into <workdir>/cmds.txt and every rc
# recorded — an rc=139 SEGFAULT must never read as a result (RESUME.md §9).
# A missing database is NAMED, never silently skipped.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
CEN=${CEN:?set CEN to the built ct204cen}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$W"; : > "$W/cmds.txt"; : > "$W/md5.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  for pair in "g_$v/slpp_all/surelog.uhdm:g.$v:g" "a_$v.uhdm:a.$v:a" "b_$v.uhdm:b.$v:b"; do
    f=${pair%%:*}; rest=${pair#*:}; out=${rest%%:*}; tg=${rest#*:}
    if [ -f "$W/$f" ]; then
      "$CEN" "$W/$f" "$tg" > "$W/cen.$out.txt" 2>>"$W/cen.err"
      echo "cen rc=$? $f rows=$(wc -l < "$W/cen.$out.txt")" >> "$W/cmds.txt"
    else : > "$W/cen.$out.txt"; echo "cen MISSING $f" >> "$W/cmds.txt"; fi
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
echo "--- nonzero rcs:"; grep '^rc=' "$W/cmds.txt" | grep -v '^rc=0 ' ; true
echo "--- cmp:"; grep -E '^cmp ' "$W/cmds.txt"; true
echo "--- SCORE (golden vs pristine vs patched), DEF and ELAB kept SEPARATE:"
for v in def elab; do
  printf "  %-4s AG+AGALL  " "$v"
  python3 "$HERE/score204.py" "$W/cen.g.$v.txt" "$W/cen.a.$v.txt" "$W/cen.b.$v.txt"
  printf "  %-4s FI        " "$v"
  python3 "$HERE/score204.py" "$W/cen.g.$v.txt" "$W/cen.a.$v.txt" "$W/cen.b.$v.txt" --rows=FI
  printf "  %-4s GvG-calib " "$v"
  python3 "$HERE/score204.py" "$W/cen.g.$v.txt" "$W/cen.g.$v.txt" "$W/cen.g.$v.txt"
done
