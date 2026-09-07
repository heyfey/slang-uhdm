#!/usr/bin/env bash
# r10uvm188repro/build188.sh — build the census instrument, linking UHDM
# STATICALLY out of ~/.local so it reads exactly the databases the corpus
# sweeps wrote, with the object model uhdm-cmp and uhdm-dump use.
set -u
D=$(cd "$(dirname "$0")" && pwd)
OUT=${OUT:-/tmp/r10uvm188_cen}
g++ -std=c++20 -O1 "$D/ct188cen.cpp" -o "$OUT" \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> $OUT"
