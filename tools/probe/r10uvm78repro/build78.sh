#!/usr/bin/env bash
# r10uvm78repro/build78.sh — build the census instrument.
#   usage: build78.sh   (writes /tmp/r10uvm78cen)
# The tool links UHDM STATICALLY out of ~/.local so it reads exactly the
# databases the corpus sweeps wrote, with the same object model uhdm-cmp and
# uhdm-dump use.
set -u
D=$(cd "$(dirname "$0")" && pwd)
g++ -std=c++20 -O1 "$D/r10uvm78cen.cpp" -o /tmp/r10uvm78cen \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> /tmp/r10uvm78cen"
