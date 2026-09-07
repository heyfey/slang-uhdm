#!/usr/bin/env bash
# r10uvm194repro/build194.sh — builds this pass's two MEASUREMENT-ONLY
# instruments against ~/.local.  Neither is an acceptance judge; the official
# ~/git-repos/UHDM/build/bin/uhdm-cmp is.
set -u
OUT=${1:-/tmp/r10uvm194_bin}
mkdir -p "$OUT"
HERE=$(cd "$(dirname "$0")" && pwd)
for t in ct194cen ct194own; do
  g++ -O2 -std=c++17 "$HERE/$t.cpp" -I "$HOME/.local/include" \
      -L "$HOME/.local/lib64" -L "$HOME/.local/lib" -luhdm -lcapnp -lkj \
      -o "$OUT/$t" || { echo "BUILD FAILED: $t"; exit 3; }
  echo "built $OUT/$t"
done
