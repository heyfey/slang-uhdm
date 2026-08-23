#!/usr/bin/env bash
# r10earl75 — PREDICT THE MOVER SET BY NAME, from the PRISTINE databases alone,
# BEFORE the patched sweep exists.  MEASUREMENT ONLY.
#
# § genScopeProcOpFoldTs75 can only ever ADD a `ref_typespec` to a constant that
# ALREADY EXISTS in the pristine database and that sits
#   * inside an `always` / `always_comb` / `always_ff` / `always_latch` written
#     in a GENERATE SCOPE (owner=always, gd>=1),
#   * with an `operation` as its DIRECT parent,
#   * carrying NO typespec today (ts=-),
#   * NOT inside a for-stmt header or body,
# and whose folded symbol is an UNQUALIFIED read of a wildcard-imported PACKAGE
# parameter (the `importedParamDefTs` + no-`::` gate the law inherits).
#
# The last condition is NOT recorded in the database, so stage 1 below is a
# deliberate OVER-approximation on the first four; stage 2 reads the source of
# every stage-1 hit and refutes the rest.  Nothing else in either corpus can
# move: the law writes no value, no size, no constant type and no new object.
#
#   usage: predict75.sh <sweep-workdir> [label]
set -u
W=${1:?workdir}; L=${2:-$W}
CEN=${CSCEN75:?set CSCEN75}
n=0; hit=0
while IFS= read -r db; do
  n=$((n+1))
  c=$(LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib "$CEN" "$db" 2>/dev/null \
      | grep -c ' always .* gd=[1-9].* ts=- ' || true)
  [ "${c:-0}" -gt 0 ] && { hit=$((hit+1)); echo "CANDIDATE $c $db"; }
done < <(find "$W" -name '*.uhdm' ! -name 'golden.uhdm' | sort)
echo "$L: scanned=$n flagged=$hit"

# ---------------------------------------------------------------------------
# STAGE 2 — refute the stage-1 over-approximation by SOURCE.  The law's gate is
# `importedParamDefTs.count(&nv.symbol)` plus "the read text contains no `::`",
# i.e. the folded symbol must be a parameter of a WILDCARD-IMPORTED package read
# UNQUALIFIED.  A test whose sources contain no `import <pkg>::*` at all cannot
# satisfy that gate for any constant, whatever stage 1 flagged.
#   usage: STAGE2=1 predict75.sh <sweep-workdir> [label]
