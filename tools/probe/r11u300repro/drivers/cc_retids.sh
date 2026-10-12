#!/bin/bash
# r11u300: build retids.cpp with the uhdm_strictcmp flags.  usage: cc_retids.sh <out>
D=$(cd "$(dirname "$0")" && pwd)
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O1 -std=gnu++20 -include uhdm/config.h \
  "$D/retids.cpp" -o "$1" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
