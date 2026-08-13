#!/usr/bin/env bash
# r10uvm69repro/gridcells.sh — print the CALL-SHAPE cell table for one arm
# workdir, golden beside ours, CONTROL beside FINAL.
#
#   usage: gridcells.sh <ctrl-wd> <final-wd> <owner-grep>
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  Golden is read from the
# CONTROL workdir and re-read from the FINAL workdir, and the two are diffed
# against each other: golden CANNOT move between our builds, so any difference
# there means the two workdirs are not the same arm and the table is void.
# GUARD: that check is fatal, not a warning.
set -u
CEN=${CALLCEN:-/tmp/r10uvm69_callcen}
C=${1:?control workdir}
F=${2:?final workdir}
G=${3:-.}
[ -x "$CEN" ] || { echo "FATAL: no callcen at $CEN"; exit 3; }
for d in "$C" "$F"; do
  [ -f "$d/slpp_all/surelog.uhdm" ] || { echo "FATAL: no golden in $d"; exit 3; }
  [ -f "$d/slang.uhdm" ] || { echo "FATAL: no ours in $d"; exit 3; }
done
fmt() { "$CEN" "$1" 2>/dev/null | grep -E "$G" | grep -v "	new	" \
        | awk -F'\t' '{print $8"  "$2"  "$3"  "$4"  "$6"  "$9}' | sort -u; }
fmt "$C/slpp_all/surelog.uhdm" > /tmp/r10uvm69_gc_g1
fmt "$F/slpp_all/surelog.uhdm" > /tmp/r10uvm69_gc_g2
if ! diff -q /tmp/r10uvm69_gc_g1 /tmp/r10uvm69_gc_g2 >/dev/null; then
  echo "FATAL: GOLDEN DIFFERS BETWEEN THE TWO WORKDIRS — not the same arm"
  diff -u /tmp/r10uvm69_gc_g1 /tmp/r10uvm69_gc_g2 | head -20
  exit 4
fi
fmt "$C/slang.uhdm" > /tmp/r10uvm69_gc_c
fmt "$F/slang.uhdm" > /tmp/r10uvm69_gc_f
echo "==== GOLDEN (LHS) ===="; cat /tmp/r10uvm69_gc_g1
echo "==== OURS CONTROL vs GOLDEN ===="
diff -u /tmp/r10uvm69_gc_g1 /tmp/r10uvm69_gc_c | sed -n '3,$p' || true
echo "differing(control)=$(diff /tmp/r10uvm69_gc_g1 /tmp/r10uvm69_gc_c | grep -cE '^[<>]')"
echo "==== OURS FINAL vs GOLDEN ===="
diff -u /tmp/r10uvm69_gc_g1 /tmp/r10uvm69_gc_f | sed -n '3,$p' || true
echo "differing(final)=$(diff /tmp/r10uvm69_gc_g1 /tmp/r10uvm69_gc_f | grep -cE '^[<>]')"
