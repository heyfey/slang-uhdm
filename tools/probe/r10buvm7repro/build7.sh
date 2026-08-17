#!/usr/bin/env bash
# r10buvm7repro/build7.sh — build the census instrument.  usage: build7.sh
# Links UHDM STATICALLY out of ~/.local so it reads exactly the databases the
# corpus sweeps wrote, with the object model uhdm-cmp and uhdm-dump use.
set -u
D=$(cd "$(dirname "$0")" && pwd)
g++ -std=c++20 -O1 "$D/r10buvm7cen.cpp" -o /tmp/r10buvm7cen \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> /tmp/r10buvm7cen"
