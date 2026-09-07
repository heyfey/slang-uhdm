#!/usr/bin/env bash
# r10uvm192 — builds this pass's three measurement instruments.  MEASUREMENT
# ONLY; the official uhdm-cmp is the judge.
#   ct192cen   — the CALL-BINDING census (CALL / SUB / PRED sections); its PRED
#                section transcribes the production fence term for term, so it
#                names the mover set from PRISTINE databases alone
#   ct192own   — the owner-finder for a head whose BOTH sides are present:
#                the failing edge on each side with its vector index and
#                neighbours, the TWIN TEST, the listing census, and the
#                DESCENT TEST that says which edge the judge took
#   ct192view  — the VIEW MAP: which package is on AllPackages (definition) and
#                which on TopPackages (elaborated), and each one's qualified-
#                entry / class-method populations
# Output goes to $CEN (default /tmp/r10uvm192_cen) so nothing lands in the
# worktree and no other pass's scratch is touched.
set -u
CEN=${CEN:-/tmp/r10uvm192_cen}
D=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$CEN" || exit 1
rc=0
for t in ct192cen ct192own ct192view; do
  g++ -O2 -std=c++17 "$D/$t.cpp" -I "$HOME/.local/include" \
      -L "$HOME/.local/lib64" -L "$HOME/.local/lib" \
      -luhdm -lcapnp -lkj -o "$CEN/$t" || rc=1
  echo "built $CEN/$t rc=$?"
done
exit $rc
