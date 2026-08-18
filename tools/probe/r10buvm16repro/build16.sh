#!/usr/bin/env bash
# r10buvm16repro/build16.sh — build the `new` census, linking UHDM STATICALLY
# out of ~/.local so it reads exactly the databases the corpus sweeps wrote,
# with the object model uhdm-cmp and uhdm-dump use.
set -u
D=$(cd "$(dirname "$0")" && pwd)
g++ -std=c++20 -O1 "$D/r10buvm16cen.cpp" -o /tmp/r10buvm16cen \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> /tmp/r10buvm16cen"
