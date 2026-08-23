#!/bin/bash
# r10uvm107repro/build107.sh — build a measurement-only probe from THIS repro
# directory.  WD defaults to this script's own worktree so the driver never
# hard-codes another pass's paths (standing ops rule).
#   build107.sh <name-without-ext> [outdir]
set -u
D=$(cd "$(dirname "$0")" && pwd)
OUT=${2:-/tmp/r10uvm107_bin}
mkdir -p "$OUT"
g++ -std=c++20 -O1 "$D/$1.cpp" -o "$OUT/$1" \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> $OUT/$1"
