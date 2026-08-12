#!/bin/bash
# r10svs3repro/svsbuild.sh — build one C++ probe from this directory against the
# INSTALLED UHDM (the same UHDM the exporter, uhdm-cmp and uhdm-dump link).
# Carried from r10uvm55repro/pbuild.sh with the output path renamed.
#
#   usage: svsbuild.sh <name-without-.cpp>   ->  /tmp/r10svs3_<name>
#
# GUARD: a compile failure is exit 1 with the compiler's own output, never a
# silent "0 rows" from a stale binary; the produced path and its md5 are printed.
set -u
N=${1:?probe name without .cpp}
HERE=$(cd "$(dirname "$0")" && pwd)
[ -f "$HERE/$N.cpp" ] || { echo "FATAL: no $HERE/$N.cpp"; exit 3; }
OUT=/tmp/r10svs3_$N
rm -f "$OUT"
g++ -std=c++20 -O1 "$HERE/$N.cpp" -o "$OUT" \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread || {
  echo "COMPILE FAILED for $N"; exit 1; }
[ -x "$OUT" ] || { echo "COMPILE produced nothing"; exit 1; }
echo "built $OUT md5=$(md5sum "$OUT" | cut -d' ' -f1)"
