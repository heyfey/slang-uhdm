#!/bin/bash
# r10ladder1/calib.sh — GATE 2: the detector must be SILENT on a database
# compared with ITSELF.
#
# A detector that flags everything is a broken detector.  This runs ctladder in
# --calib mode, which restores the SAME golden file TWICE into two independent
# Serializers (different pointers, real walk, no identity short-circuit) and
# requires ZERO rungs.  ctladder itself exits 5 if a calibration produces any.
#
#   usage: calib.sh <workdir> <mode:name> [<mode:name> ...]
#
# GUARD: a row whose golden cannot be resolved is a FAIL, not a skip — a
# calibration that compared nothing would trivially print zero heads.
set -u
WD=${1:?workdir}; shift
LAD=${CTLADDER:-$(dirname "$0")/ctladder}
[ -x "$LAD" ] || { echo "FATAL: no ctladder at $LAD"; exit 3; }
ok=0; bad=0
printf "%-9s %-14s %10s %8s %s\n" MODE TEST GOLDENOBJS RUNGS VERDICT
for spec in "$@"; do
  mode=${spec%%:*}; n=${spec#*:}
  for d in "$WD/$mode/$n"-*/; do
    [ -d "$d" ] || continue
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ]; then
      printf "%-9s %-14s %10s %8s %s\n" "$mode" "$n" - - FAIL-NOGOLDEN; bad=$((bad+1)); continue
    fi
    T=$("$LAD" "$G" "$G" --calib 2>&1); rc=$?
    r=$(sed -n 's/.*rungs=\([0-9]*\).*/\1/p' <<<"$T" | head -1)
    g=$(sed -n 's/.*golden_objs=\([0-9]*\).*/\1/p' <<<"$T" | head -1)
    if [ "$rc" -eq 0 ] && [ "${r:-x}" = "0" ] && [ "${g:-0}" -gt 0 ]; then
      printf "%-9s %-14s %10s %8s %s\n" "$mode" "$n" "$g" "$r" "ZERO-HEADS"; ok=$((ok+1))
    else
      printf "%-9s %-14s %10s %8s %s\n" "$mode" "$n" "${g:--}" "${r:--}" "FAIL(rc=$rc)"; bad=$((bad+1))
    fi
  done
done
echo "-- ZERO-HEADS=$ok FAIL=$bad"
[ "$bad" -eq 0 ] || exit 1
