#!/usr/bin/env bash
# r10v190 (verifier) — builds the deep census.  MEASUREMENT ONLY; the official
# ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole acceptance judge.
# Output goes to $VCEN (default /tmp/r10v190_cen) so nothing lands in the tree.
set -u
VCEN=${VCEN:-/tmp/r10v190_cen}
D=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$VCEN" || exit 1
g++ -O2 -std=c++17 "$D/ctv190cen.cpp" -I "$HOME/.local/include" \
    -L "$HOME/.local/lib64" -L "$HOME/.local/lib" \
    -luhdm -lcapnp -lkj -o "$VCEN/ctv190cen"
echo "built $VCEN/ctv190cen rc=$?"
