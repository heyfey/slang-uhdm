#!/bin/bash
# r10uvm41 — build every probe binary the metric panel needs, STATIC against
# the installed UHDM/capnp/kj so no LD_LIBRARY_PATH is involved.
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
LIBS="$HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread"
for n in "$@"; do
  out=/tmp/r10uvm41_$n
  [ -x "$out" ] && { echo "have $n"; continue; }
  g++ -std=c++20 -O2 "tools/probe/$n.cpp" -o "$out" \
      -I"$HOME/.local/include" $LIBS 2> "/tmp/r10uvm41_pb_$n.log"
  echo "$n rc=$? -> $out"
  [ -x "$out" ] || tail -5 "/tmp/r10uvm41_pb_$n.log"
done
