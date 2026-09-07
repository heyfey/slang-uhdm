#!/bin/bash
# r10uvm190 — builds this pass's four measurement instruments.  MEASUREMENT
# ONLY; the official uhdm-cmp is the judge.
#   ct190cen   — the census: PA (param_assign Rhs presence), TDC (typedef-alias
#                clone range bounds) and TDCE (the enum-base clones only)
#   ct190own   — the MIRROR owner-finder (carried from r10uvm164repro)
#   ct190path  — the lock-step DESCENT that names the pair the judge stopped on
#   ct190mask  — family / leave-one-out masking of the OFFICIAL design::Compare,
#                the instrument that actually named THIS head's owner
# Output goes to $CEN (default /tmp/r10uvm190_cen) so nothing lands in the
# worktree and no other pass's scratch is touched.
set -u
CEN=${CEN:-/tmp/r10uvm190_cen}
D=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$CEN" || exit 1
rc=0
for t in ct190cen ct190own ct190path ct190mask; do
  g++ -O2 -std=c++17 "$D/$t.cpp" -I "$HOME/.local/include" \
      -L "$HOME/.local/lib64" -L "$HOME/.local/lib" \
      -luhdm -lcapnp -lkj -o "$CEN/$t" || rc=1
  echo "built $CEN/$t rc=$?"
done
exit $rc
