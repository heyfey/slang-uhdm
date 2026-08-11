#!/bin/bash
# r10uvm47 (cloned from pass 46) (cloned from pass 45) (cloned from pass 44) — build a probe binary STATIC against the installed UHDM/capnp/kj so
# no LD_LIBRARY_PATH is involved.  Same recipe as r10uvm41repro/probebuild.sh,
# with this pass's /tmp namespace so a sibling worktree cannot clobber it.
set -u
ROOT=$(cd "$(dirname "$0")"/../../.. && pwd)
cd "$ROOT" || exit 1
LIBS="$HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread"
for n in "$@"; do
  out=/tmp/r10uvm47_$n
  g++ -std=c++20 -O2 "tools/probe/$n.cpp" -o "$out" \
      -I"$HOME/.local/include" $LIBS 2> "/tmp/r10uvm47_pb_$n.log"
  echo "$n rc=$? -> $out"
  [ -x "$out" ] || tail -20 "/tmp/r10uvm47_pb_$n.log"
done
