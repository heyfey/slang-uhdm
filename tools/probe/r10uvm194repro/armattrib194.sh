#!/usr/bin/env bash
# r10uvm194repro/armattrib194.sh — ORDER-BLIND attribution for a GRID/BOUNDARY
# ARM workdir (attrib194.sh does the same for a verify_golden workdir, where
# both sides are named `slang.uhdm` under the same relative path).
#
# The two databases here are `a_<view>.uhdm` and `b_<view>.uhdm`, so the dump's
# own first line ("<path>: Restored design Pre-Elab:") names the FILE and would
# read as two unattributed lines in every arm.  It is normalised away, which is
# the whole reason this script exists rather than reusing attrib194.sh.
#
#   usage: armattrib194.sh <arm workdir> [<arm workdir> ...]
set -u
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
tot=0; una=0
norm() { "$DUMP" "$1" 2>/dev/null | sed -e '1s|^.*: Restored|DB: Restored|' \
           -e "s|$2||g" | sort; }
for W in "$@"; do
  for v in def elab; do
    a="$W/a_$v.uhdm"; b="$W/b_$v.uhdm"
    [ -f "$a" ] && [ -f "$b" ] || continue
    A=$(mktemp); B=$(mktemp)
    norm "$a" "$W/" > "$A"; norm "$b" "$W/" > "$B"
    d=$(comm -3 "$A" "$B" | grep -c . ; true)
    u=$(comm -3 "$A" "$B" | grep -avE 'vpiActual|_(bit_select|part_select|indexed_part_select|var_select): ' | grep -c . ; true)
    echo "$(basename "$W") $v sorted-diff-lines=$d UNATTRIBUTED=$u"
    [ "$u" -gt 0 ] && comm -3 "$A" "$B" | grep -avE 'vpiActual|_(bit_select|part_select|indexed_part_select|var_select): ' | head -20
    tot=$((tot+d)); una=$((una+u))
    rm -f "$A" "$B"
  done
done
echo "-- TOTAL sorted-diff lines=$tot UNATTRIBUTED=$una"
