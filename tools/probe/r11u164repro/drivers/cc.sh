#!/bin/bash
# Build predict164 with the uhdm_strictcmp target flags (copy of r11u157hp/drivers/cc.sh). usage: cc.sh <out>
# usage: cc.sh <out>
D=$(cd "$(dirname "$0")" && pwd)
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O3 -DNDEBUG -std=gnu++20 -include uhdm/config.h \
  "$D/predict164.cpp" -o "$1" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
