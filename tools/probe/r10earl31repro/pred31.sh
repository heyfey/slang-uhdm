#!/usr/bin/env bash
# r10earl31 — THE SOURCE-DERIVED MOVER PREDICTION, run BEFORE the patch was
# measured (the brief's requirement, and the thing the last two passes got wrong).
#
# § psBoundPkgParamTs31 can only touch a constant that is (i) a fold of a PACKAGE
# PARAMETER and (ii) sitting in a part_select's LEFT or RIGHT range.  Requirement
# (ii) is a SOURCE property: the test must contain a RANGE SELECT (`[a:b]`, not
# `[i]`, not `[b +: w]`) whose bound text names something other than a literal.
# So the candidate row set is computable from the sources alone:
#
#   A  a range select whose bound text contains `::`         (a qualified read)
#   B  a range select whose bound text contains an IDENTIFIER, in a file that
#      also wildcard-imports a package                        (an imported read)
#
# A ∪ B is an UPPER BOUND on the rows the law can move: every measured mover must
# be in it, and a mover outside it falsifies the gate.  It is deliberately loose
# (it cannot tell a package parameter from a module localparam, and it does not
# parse), which is the right direction for a fence.
#
#   usage: ./pred31.sh <corpus-root> [<corpus-root> ...]
set -u
RANGE='\[[^]:]*[A-Za-z_][^]:]*:[^]]*\]'
for root in "$@"; do
  echo "=== $root"
  A=0; B=0; T=0
  while IFS= read -r f; do
    T=$((T+1))
    hasq=0; hasi=0
    grep -qE "\[[^]]*::[^]]*:[^]]*\]" "$f" 2>/dev/null && hasq=1
    if grep -qE "^[[:space:]]*import[[:space:]]+[A-Za-z_][A-Za-z_0-9]*::\*" "$f" 2>/dev/null; then
      grep -qE "$RANGE" "$f" 2>/dev/null && hasi=1
    fi
    [ $hasq = 1 ] && { A=$((A+1)); echo "A $f"; }
    [ $hasq = 0 ] && [ $hasi = 1 ] && { B=$((B+1)); echo "B $f"; }
  done < <(find "$root" -type f \( -name '*.sv' -o -name '*.v' -o -name '*.svh' \) 2>/dev/null)
  echo "--- $root files=$T qualified-range(A)=$A imported-range(B)=$B"
done
