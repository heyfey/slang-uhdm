#!/usr/bin/env bash
# r10earl122 — GENERATE the singular-edge field table read by own122.cpp.
#
# MEASUREMENT ONLY.  The official `uhdm-cmp` stays the sole acceptance judge.
#
# WHY.  `BaseClass::SafeCompare(lhs, rhs, ctx)` with `rhs == nullptr`
# (~/.local/include/uhdm/BaseClass.h:187-199) sets ONLY `m_failedLhs`, and sets
# it to the POINTEE.  So a `LHS: <logic_var>` / `RHS: <null>` head names the
# TARGET of a golden edge and HIDES the owner.  r10earl120's `own120` answered
# the same question for a `package` target with a HAND-WRITTEN field list; a
# `variables` target can sit in far more fields, so this pass DERIVES the list
# from UHDM's own generated `Compare` bodies instead of typing it out.
#
# HOW.  For every generated `<kind>::Compare`
# (~/git-repos/UHDM/build/generated/src/<kind>.cpp) take every SINGULAR
# `SafeCompare(lhs->F(), rhs->F(), ...)` — the compared singular relations, the
# only ones the judge can trip over — and look F's DECLARED type up in
# ~/.local/include/uhdm/<kind>.h.  Keep the fields whose declared type can hold
# a `logic_var`: `any`, `expr` (a `variables` IS-A `simple_expr` IS-A `expr`)
# and `variables` itself.  Everything else (typespec-, instance-, function-,
# clocking_block-typed, ...) cannot.
#
# usage: bash gen_pointsat122.sh > pointsat122.inc
set -u
GEN=${GEN:-$HOME/git-repos/UHDM/build/generated/src}
INC=${INC:-$HOME/.local/include/uhdm}
n=0
for f in "$GEN"/*.cpp; do
    k=$(basename "$f" .cpp)
    for fld in $(grep -o 'SafeCompare(lhs->[A-Za-z_]*(), rhs->' "$f" |
                 sed 's/SafeCompare(lhs->\([A-Za-z_]*\)().*/\1/' | sort -u); do
        t=$(grep -oP '^\s+const \K[a-z_]+(?=\* '"$fld"'\(\) const)' \
              "$INC/$k.h" 2>/dev/null | head -1)
        case "$t" in
            any|expr|variables) ;;
            *) continue ;;
        esac
        n=$((n + 1))
        printf '    if (const %s* p_%d = any_cast<const %s*>(a)) if ((const BaseClass*)p_%d->%s() == tgt) return "%s::%s";\n' \
               "$k" "$n" "$k" "$n" "$fld" "$k" "$fld"
    done
done
printf '    // FIELDS=%d\n' "$n"
