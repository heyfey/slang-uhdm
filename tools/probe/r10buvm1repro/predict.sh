#!/usr/bin/env bash
# r10buvm1 A-PRIORI MOVER PREDICTION, computed from the PRISTINE side ALONE so
# it cannot be fitted to the byte verifier's answer.
#
#   usage: predict.sh <pristine-workdir-root>
#
# RULE, fixed BEFORE gate 5 was run: a database MOVES iff its PRISTINE dump holds
# an UNCOLLAPSED `::`-rooted chain.  That takes exactly TWO shapes in this
# emitter and BOTH have to be counted — the first cut of this predictor counted
# only (a) and would have silently missed every STATEMENT-position cell, which is
# half the law:
#   (a) EXPRESSION form — an object whose vpiName is `X::Y.Z` (a hier_path).
#   (b) STATEMENT  form — a `method_func_call` whose `vpiPrefix` ref_obj has a
#       vpiName of `X::Y`; the CALL's own name is the bare method and contains
#       no `::` at all, so rule (a) cannot see it.
#
# WHY NOT grep THE `.uhdm` FILES DIRECTLY: measured, and it is BLIND.
# `grep -ac uvm_deferred_init.push_back` returns 0 on BOTH the pristine and the
# patched BuildUVMPkg database even though uhdm-dump prints that exact name and
# the file grew 78 bytes — the name is not a contiguous byte string in the
# serialized capnp.  A predictor that returns 0 for a database it can be PROVED
# to move returns 0 for everything, and reads exactly like a clean prediction.
#
# GUARD: a database that fails to dump counts as 0/0 and is NOT silently
# dropped from the denominator — the scanned total is printed.
set -u
R=${1:?pristine workdir root}
D=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -d "$R" ] || { echo "FATAL: no workdir $R"; exit 3; }
[ -x "$D" ] || { echo "FATAL: no uhdm-dump at $D"; exit 3; }
n=0
tot=0
for f in $(cd "$R" && find . -name slang.uhdm | sort); do
  tot=$((tot + 1))
  read -r a b <<<"$("$D" "$R/$f" 2>/dev/null | awk '
    /vpiName:[A-Za-z_][A-Za-z_0-9]*::[A-Za-z_][A-Za-z_0-9]*\./ { x++ }
    /\|vpiPrefix:/ { pfx = 3; next }
    pfx > 0 { pfx--
              if ($0 ~ /vpiName:[A-Za-z_][A-Za-z_0-9]*::[A-Za-z_][A-Za-z_0-9]*$/) { y++; pfx = 0 } }
    END { print x+0, y+0 }')"
  a=${a:-0}; b=${b:-0}
  if [ "$a" -gt 0 ] || [ "$b" -gt 0 ]; then
    echo "PREDICT $(echo "$f" | sed 's|^\./||; s|/slang.uhdm||')  exprForm=$a stmtForm=$b"
    n=$((n + 1))
  fi
done
echo "SCANNED: $tot databases"
echo "PREDICTED MOVERS: $n"
