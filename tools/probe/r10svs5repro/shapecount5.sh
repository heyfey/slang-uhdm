#!/bin/bash
# r10svs5repro/shapecount5.sh — THE PER-SHAPE COUNT for
# § vifClockingPathComponent5, keyed on the shapes THIS LAW creates and destroys,
# in golden / pristine-ours / patched-ours.
#
# WHY A SHAPE COUNT AND NOT THE MULTISET AGGREGATE: `msmovers.sh` keys on the
# WHOLE dump line, SPAN INCLUDED, so an object whose NAME converged but whose
# SPAN is (pre-existing) wrong reads as `G=0 P=0 A=1  DIVERGED`. That is exactly
# what SimpleUVM/SeqDriver do at `m_if.cb.result`, where golden puts the object at
# the MACRO DEFINITION site (116:15) and both our binaries put it at the CALL site
# (33:21). Keyed on the NAME — the only field `hier_path::Compare` reads — the
# same object is G=1 P=0 A=1, CONVERGED. Both keys are reported here, side by
# side, so the difference is visible instead of arbitrated.
#
#   usage: shapecount5.sh <golden.dump> <pristine_ours.dump> <patched_ours.dump>
#
# GUARDS: all three inputs non-empty-checked (exit 6, never a silent 0/0/0, which
# would read exactly like "the law did not fire"). Every count is printed WITH
# the regex that produced it so the reader can re-run it by hand.
set -u
G=${1:?golden dump}
P=${2:?pristine ours dump}
A=${3:?patched ours dump}
for f in "$G" "$P" "$A"; do
  [ -s "$f" ] || { echo "NO_OUTPUT: missing or empty $f"; exit 6; }
done
c() { grep -Ec "$2" "$1" || true; }
row() { printf "  %-46s G=%-6s P=%-6s A=%-6s  re=%s\n" "$1" \
        "$(c "$G" "$2")" "$(c "$P" "$2")" "$(c "$A" "$2")" "$2"; }
echo "  (G=golden  P=pristine ours  A=patched ours; whole dump, indent-blind)"
# THE SHAPE THE LAW CREATES — a hier_path NAME with a THREE-OR-MORE-component
# dotted path whose SECOND component is a clocking block or nested instance.
# `vpiName` is the field hier_path::Compare reads, so this row is the law itself.
row 'hier_path NAME <h>.<mid>.<leaf> (3-component)' '^ *\|vpiName:[A-Za-z_][A-Za-z0-9_]*(\[[^]]*\])?\.[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_]'
# The RECOVERED ELEMENT itself: a bare intermediate ref_obj named for a clocking
# block. Counted by NAME LINE (span-free) and again WITH the span.
row 'bare middle element  |vpiName:cb'            '^ *\|vpiName:cb$'
row 'ref_obj: (cb) WITH span (span-keyed)'        '\\_ref_obj: \(cb\), line:'
# THE SHAPE THE LAW DESTROYS — the 2-component name that erased the component.
row 'hier_path NAME <h>.<leaf> (2-component)'     '^ *\|vpiName:[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*$'
# CONTROLS the law must NOT touch: a modport member path and an event control on
# the clocking block itself both stay 2-component, and `vpiSigned` /
# `class_typespec` / `vpiTypedefAlias` are the three shapes the campaign's
# BUILD-DEPENDENT UVM alias churn moves — a nonzero delta there means the mover
# is not attributable to this law alone.
row 'CONTROL vpiSigned'                           '\|vpiSigned'
row 'CONTROL class_typespec'                      '\\_class_typespec'
row 'CONTROL vpiTypedefAlias'                     '\|vpiTypedefAlias'
