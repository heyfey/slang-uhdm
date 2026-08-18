#!/usr/bin/env bash
# r10rgg16repro/build16.sh — build the interface_inst census instrument,
# linking UHDM STATICALLY out of ~/.local so it reads exactly the databases the
# corpus sweeps wrote, with the object model uhdm-cmp and uhdm-dump use.
set -u
D=$(cd "$(dirname "$0")" && pwd)
g++ -std=c++20 -O1 "$D/pvcensus16.cpp" -o /tmp/r10rgg16_pvcensus \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> /tmp/r10rgg16_pvcensus"
