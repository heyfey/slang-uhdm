#!/bin/bash
# r10svs4repro/shapecount.sh — THE PER-SHAPE COUNT the brief mandates alongside
# the multiset judgement: for the EXACT shapes § thisPathSelectErased4 destroys
# and creates, count them indent-blind in golden / pristine-ours / patched-ours.
#
# This is the check that a multiset aggregate CANNOT make. On BuildUVMPkg the
# aggregate key `|vpiFullName:...release_region::i` read G=8 P=8 A=6 and
# classified as DIVERGED -- and the per-CONTEXT breakdown showed golden's 8 were
# `delete(i)` call arguments while our 8 were spurious path indices: TWO
# UNRELATED ERRORS CANCELLING in the total. Only a shape count keyed on the
# construct under test can say whether the law itself landed.
#
#   usage: shapecount.sh <golden.dump> <pristine_ours.dump> <patched_ours.dump>
#
# GUARDS: all three inputs non-empty-checked (exit 6). Counts use `grep -Fc` on
# FIXED strings wherever the pattern is fixed, and the ONE regex used is printed
# with its count so the reader can re-run it.
set -u
G=${1:?golden dump}
P=${2:?pristine ours dump}
A=${3:?patched ours dump}
for f in "$G" "$P" "$A"; do
  [ -s "$f" ] || { echo "NO_OUTPUT: missing or empty $f"; exit 6; }
done
c() { grep -Ec "$1" "$2" || true; }
row() { # $1 = label, $2 = regex
  printf "  %-52s G=%-6s P=%-6s A=%-6s\n" "$1" \
      "$(c "$2" "$G")" "$(c "$2" "$P")" "$(c "$2" "$A")"
}
echo "  (G=golden  P=pristine ours  A=patched ours; indent-blind, whole dump)"
# THE SHAPE THE LAW DESTROYS: a this-rooted hier_path whose NAME carries an index.
row 'hier_path (this.*[...]) -- name carries an index' '\\_hier_path: \(this\.[^)]*\['
# THE SHAPE THE LAW CREATES: a this-rooted hier_path with a BARE dotted name.
row 'hier_path (this.*) -- bare dotted name'           '\\_hier_path: \(this\.[^)[]*\)'
# The element kinds under a this-rooted path.
row 'bit_select whose fullname holds "this.<m>["'      '\\_bit_select: \([^)]*this\.[^)]*\['
row 'var_select whose fullname holds "this.<m>["'      '\\_var_select: \([^)]*this\.[^)]*\['
# The CONTROL: a HANDLE-rooted indexed path must be UNTOUCHED by the law.
row 'CONTROL bit_select fullname with "::" and "[" '   '\\_bit_select: \([^)]*::[^)]*\['
