#!/bin/bash
# cc176.sh <src.cpp> <out>: build a UHDM reader with the uhdm_strictcmp target's flags.
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O2 -std=gnu++20 -include uhdm/config.h \
  "$1" -o "$2" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
