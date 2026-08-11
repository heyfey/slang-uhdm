#!/bin/bash
# r10uvm48 — print ONE arm cell's statement tree out of a uhdm-dump, both sides,
# side by side in sequence.  A cell is named by the METHOD name (`vpiName:<cell>`
# on a `function:` line), and the printer walks forward until the next
# `|vpiMethod:`/`|vpiTaskFunc:` sibling, so a cell is never confused with its
# neighbour.
# POSITIVE CONTROL: a cell name that appears in NEITHER dump prints
# `CELL-NOT-FOUND` and returns 4 — it never prints an empty tree that could read
# as "golden emits nothing".
#   usage: cell.sh <golden.dump> <ours.dump> <cellname>...
set -u
G=${1:?}; shift
O=${1:?}; shift
[ -s "$G" ] || { echo "FATAL: no golden dump $G"; exit 3; }
[ -s "$O" ] || { echo "FATAL: no ours dump $O"; exit 3; }
rc=0
for C in "$@"; do
  found=0
  for side in GOLDEN OURS; do
    [ "$side" = GOLDEN ] && F=$G || F=$O
    ln=$(grep -n "^ *\\\\_function: (.*::$C), \|^ *\\\\_task: (.*::$C), " "$F" | head -1 | cut -d: -f1)
    if [ -z "$ln" ]; then
      echo "=== $C $side: CELL-NOT-FOUND"
      continue
    fi
    found=1
    echo "=== $C $side (dump line $ln)"
    awk -v s="$ln" 'NR>s && /^ *\|vpi(Method|TaskFunc|Instance):$/ {exit} NR>=s {print}' "$F" \
      | sed 's#/home/[^ ,]*/##g'
  done
  [ "$found" = 1 ] || rc=4
done
exit $rc
