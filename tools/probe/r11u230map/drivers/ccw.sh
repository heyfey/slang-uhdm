#!/bin/bash
# Build drivers/fieldoff.cpp (the span-field offsets for pinwriter.py) with the uhdm_strictcmp target's flags.
# usage: ccw.sh <out>
D=$(cd "$(dirname "$0")" && pwd)
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O1 -std=gnu++20 -include uhdm/config.h \
  "$D/fieldoff.cpp" -o "$1" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
