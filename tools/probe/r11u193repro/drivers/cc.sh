#!/bin/bash
# r11u193: build a driver tool against the ~/.local UHDM (the strict comparator's flags).  usage: cc.sh <src.cpp> <out>
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O2 -DNDEBUG -std=gnu++20 -include uhdm/config.h \
  "$1" -o "$2" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
