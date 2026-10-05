#!/bin/bash
# (r11u247: copied from r11u244repro/drivers)
# (r11u244: copied from r11u242repro/drivers)
# (r11u240: copied from r11u238repro/drivers)
# (r11u242: copied from r11u240repro/drivers)
# (r11u238 (from r11u236repro): copied from tools/probe/r11u211map/drivers/cc.sh)
# Build the variant comparator with the uhdm_strictcmp target's exact flags (build/CMakeFiles/uhdm_strictcmp.dir).
# usage: cc.sh <out>
D=$(cd "$(dirname "$0")" && pwd)
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O3 -DNDEBUG -std=gnu++20 -include uhdm/config.h \
  "$D/strictcmp_x.cpp" -o "$1" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
