#!/usr/bin/env bash
# r10buvm32repro/build32.sh — build the SCOPED-CALL census, linking UHDM STATICALLY
# out of ~/.local so it reads exactly the databases the corpus sweeps wrote.
set -u
D=$(cd "$(dirname "$0")" && pwd)
SRC=${2:-$D/r10buvm32cen.cpp}
OUT=${1:-/tmp/r10buvm32cen}
g++ -std=c++20 -O1 "$SRC" -o "$OUT" \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> $OUT"
