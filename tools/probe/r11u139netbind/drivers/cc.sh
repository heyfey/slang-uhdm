#!/bin/bash
# Build a UHDM measurement driver with the uhdm_strictcmp target's flags. usage: cc.sh <src.cpp> <out>
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O2 -DNDEBUG -std=gnu++20 -include uhdm/config.h \
  "$1" -o "$2" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
