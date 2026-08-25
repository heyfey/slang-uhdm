#!/bin/bash
# r10uvm135repro/build135.sh — build a MEASUREMENT-ONLY probe from THIS repro
# directory.  Never hard-codes another pass's paths.
#   build135.sh <name-without-ext> [outdir]
set -u
D=$(cd "$(dirname "$0")" && pwd)
OUT=${2:-/tmp/r10uvm135_bin}
mkdir -p "$OUT"
g++ -std=c++20 -O1 "$D/$1.cpp" -o "$OUT/$1" \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> $OUT/$1"
