#!/bin/bash
# Build bindcls with the uhdm_strictcmp target's flags (as r11u319repro/drivers/cc_x.sh). usage: cc_bindcls.sh <out>
D=$(cd "$(dirname "$0")" && pwd)
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O3 -DNDEBUG -std=gnu++20 -include uhdm/config.h \
  "$D/bindcls.cpp" -o "$1" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
