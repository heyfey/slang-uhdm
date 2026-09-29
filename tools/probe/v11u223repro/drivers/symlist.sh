#!/bin/bash
# symlist.sh <out>: build r11u223repro's symbol-table lister (tools/probe/r11u223repro/drivers/tool/symlist.cpp) with the
# flags of tools/probe/r11u211map/drivers/cc.sh.
R=$(cd "$(dirname "$0")/../../../.." && pwd)
/opt/rh/gcc-toolset-14/root/usr/bin/c++ -DPLI_DLLESPEC="" -DPLI_DLLISPEC="" -isystem $HOME/.local/include -O2 -DNDEBUG -std=gnu++20 -include uhdm/config.h \
  $R/tools/probe/r11u223repro/drivers/tool/symlist.cpp -o "$1" $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -ldl -lutil -lm -lrt -lpthread
