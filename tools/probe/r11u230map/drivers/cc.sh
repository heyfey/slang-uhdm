#!/bin/bash
# Build a UHDM tool of this directory (strictcmp_x.cpp by default; objrank.cpp, sym.cpp, ord.cpp) with the
# uhdm_strictcmp target's exact flags (build/CMakeFiles/uhdm_strictcmp.dir).   usage: cc.sh <out> [<source .cpp>]
D=$(cd "$(dirname "$0")" && pwd); SRC=${2:-$D/strictcmp_x.cpp}
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O3 -DNDEBUG -std=gnu++20 -include uhdm/config.h \
  "$SRC" -o "$1" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
