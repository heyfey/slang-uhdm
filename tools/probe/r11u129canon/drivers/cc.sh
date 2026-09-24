#!/bin/bash
# cc.sh <src.cpp> <out>: compile one UHDM tool with uhdm-strictcmp's exact flags (build/CMakeFiles/uhdm_strictcmp.dir).
set -e
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O3 -DNDEBUG -std=gnu++20 -include uhdm/config.h \
  "$1" -o "$2" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
