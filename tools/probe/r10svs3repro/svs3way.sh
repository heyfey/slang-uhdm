#!/bin/bash
# r10svs3repro/svs3way.sh — THE 3-WAY PER-SHAPE CENSUS: golden vs pristine-ours
# vs patched-ours.
#
# WHY IT EXISTS, and it is a CORRECTION of svsmovers.sh in this same directory.
# svsmovers.sh applies the standing rule "a REMOVED line that GOLDEN HAS is a
# FINDING".  That rule is exact for a shape that occurs ONCE, and WRONG for a
# shape that occurs many times: if golden has 691 copies of a line and we have
# 50, removing 2 of ours is reported as a finding while the only question that
# matters is whether OUR count moved TOWARD or AWAY FROM golden's.  On this
# pass's GATE 5 that heuristic produced 12 "findings" on testflags/SeqDriver,
# every one of them a `uvm_reg_data_t`/`uvm_reg_addr_t` typespec-alias shape, and
# every one of them explained by parallel-parse nondeterminism on the PRISTINE
# side rather than by the law (see README §6.2).
#
#   usage: svs3way.sh <golden.dump> <pristine.dump> <patched.dump> < shapes.txt
#     shapes.txt: one whole dump line per row, INDENTATION KEPT.
#
# Per shape it prints the three counts and a verdict computed from the DISTANCE
# to golden before and after:
#     CONVERGED            |patched-golden| <  |pristine-golden|
#     *** DIVERGED ***     |patched-golden| >  |pristine-golden|
#     unchanged distance   equal
#
# GUARDS / TRAPS ENCODED:
#   * the lookup is `grep -Fxc` on the WHOLE line with INDENTATION KEPT — uhdm-dump
#     encodes depth as leading spaces and a sibling instrument in this campaign
#     reported distance 0 for a pure re-parenting by stripping it.
#   * all three inputs must already have uhdm-dump's FIRST LINE (the database
#     path) stripped with `sed 1d`; a missing or empty input is exit 6, never a
#     verdict of 0.
#   * a DIVERGED verdict on a GENERIC depth-keyed property line (`|vpiParent:`,
#     `|vpiActual:`, `|vpiStmt:`) is usually NOT law-owned: those aggregates are
#     dominated by unrelated objects at the same depth.  Read the shape, do not
#     net the verdicts.
#   * PREFER SERIAL re-runs of both binaries as inputs.  A sweep workdir produced
#     at `--jobs 2` can flip content at CONSTANT byte size for UVM tests, which
#     makes the pristine column an unstable reference.
set -u
G=${1:?golden dump}
P=${2:?pristine-ours dump}
A=${3:?patched-ours dump}
for f in "$G" "$P" "$A"; do
  [ -s "$f" ] || { echo "NO_OUTPUT: missing or empty $f"; exit 6; }
done
conv=0; div=0; same=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  g=$(grep -Fxc -- "$line" "$G" || true); g=${g:-0}
  p=$(grep -Fxc -- "$line" "$P" || true); p=${p:-0}
  a=$(grep -Fxc -- "$line" "$A" || true); a=${a:-0}
  db=$(( p > g ? p - g : g - p ))
  da=$(( a > g ? a - g : g - a ))
  if   [ "$da" -lt "$db" ]; then v="CONVERGED  ($db -> $da)";            conv=$((conv+1))
  elif [ "$da" -gt "$db" ]; then v="*** DIVERGED ($db -> $da) ***";      div=$((div+1))
  else                          v="unchanged distance ($db)";           same=$((same+1))
  fi
  printf 'golden=%-6s pristine=%-6s patched=%-6s %s\n    %s\n' "$g" "$p" "$a" "$v" "$line"
done
echo "---- shapes: CONVERGED=$conv DIVERGED=$div UNCHANGED=$same"
