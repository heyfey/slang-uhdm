#!/usr/bin/env bash
# r10rgg12repro/build12.sh — build the range-bound census instrument, linking
# UHDM STATICALLY out of ~/.local so it reads exactly the databases the corpus
# sweeps wrote, with the object model uhdm-cmp and uhdm-dump use.
set -u
D=$(cd "$(dirname "$0")" && pwd)
g++ -std=c++20 -O1 "$D/rcensus12.cpp" -o /tmp/r10rgg12_rcensus \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> /tmp/r10rgg12_rcensus"
