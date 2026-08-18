#!/usr/bin/env bash
# r10buvm18repro/build17.sh — build the parameter-typespec census, linking
# UHDM STATICALLY out of ~/.local so it reads exactly the databases the corpus
# sweeps wrote, with the object model uhdm-cmp and uhdm-dump use.
set -u
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-/tmp/r10buvm18probe}
g++ -std=c++20 -O1 "$D/r10buvm18probe.cpp" -o "$OUT" \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> $OUT"
