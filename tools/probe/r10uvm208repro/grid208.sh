#!/usr/bin/env bash
# r10uvm208repro/grid208.sh — the arm driver (r10uvm205repro/grid205.sh form).
# MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
#
#   CEN=<ct208cen> grid208.sh <file.sv> <binA:pristine> <binB:patched> <workdir>
#
# ONE REAL SURELOG GOLDEN and BOTH binaries' databases, in BOTH views, with
# every command AND ITS BINARY PATH echoed into <workdir>/cmds.txt and every rc
# recorded — an rc=139 SEGFAULT must never read as a result (RESUME.md §9).
# A missing database is NAMED, never silently skipped.
set -u
SV=$(readlink -f "$1"); A=$2; B=$3; W=$4
CEN=${CEN:?set CEN to the built ct208cen}
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
  G="$W/g_$v/slpp_all/surelog.uhdm"
  # GOLDEN-VS-GOLDEN CALIBRATION FIRST (RESUME.md §9): the census must read
  # zero movers when both sides are the same golden database.
  if [ -f "$G" ]; then
    "$CEN" "$G" "$G" --raw > "$W/raw.g.$v.txt" 2>>"$W/cen.err"
    echo "cen rc=$? g $v rows=$(grep -c '^RAW' "$W/raw.g.$v.txt")" >> "$W/cmds.txt"
  else : > "$W/raw.g.$v.txt"; echo "cen MISSING g $v" >> "$W/cmds.txt"; fi
  for s in a b; do
    if [ -f "$G" ] && [ -f "$W/${s}_$v.uhdm" ]; then
      "$CEN" "$G" "$W/${s}_$v.uhdm" --raw > "$W/raw.$s.$v.txt" 2>>"$W/cen.err"
      echo "cen rc=$? $s $v rows=$(grep -c '^RAW' "$W/raw.$s.$v.txt")" >> "$W/cmds.txt"
    else
      : > "$W/raw.$s.$v.txt"; echo "cen MISSING $s $v (G=$([ -f "$G" ] && echo ok || echo NO) O=$([ -f "$W/${s}_$v.uhdm" ] && echo ok || echo NO))" >> "$W/cmds.txt"
    fi
  done
  for s in a b; do
    if [ -f "$G" ] && [ -f "$W/${s}_$v.uhdm" ]; then
      "$CMP" "$G" "$W/${s}_$v.uhdm" > "$W/cmp.$s.$v.txt" 2>&1
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
echo "--- cen/cmp:"; grep -E '^(cen|cmp) ' "$W/cmds.txt"; true
echo "--- BYTE-IDENTICAL between the two binaries?"
for v in def elab; do
  if [ -f "$W/a_$v.uhdm" ] && [ -f "$W/b_$v.uhdm" ]; then
    if cmp -s "$W/a_$v.uhdm" "$W/b_$v.uhdm"; then echo "  $v IDENTICAL"; else echo "  $v DIFFERS"; fi
  else echo "  $v MISSING"; fi
done
echo "--- SCORE (golden vs pristine vs patched), DEF and ELAB kept SEPARATE:"
for v in def elab; do
  printf "  %-4s ALL       " "$v"
  python3 "$HERE/score208.py" "$W/raw.a.$v.txt" "$W/raw.b.$v.txt"
  printf "  %-4s .elem     " "$v"
  python3 "$HERE/score208.py" "$W/raw.a.$v.txt" "$W/raw.b.$v.txt" --filter='| .elem'
  printf "  %-4s GvG-calib " "$v"
  python3 "$HERE/score208.py" "$W/raw.g.$v.txt" "$W/raw.g.$v.txt"
done
