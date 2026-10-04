#!/bin/bash
# (r11u232) cc_objid.sh <out>: build drivers/objid.cpp against the UHDM the exporter links (~/.local).
D=$(cd "$(dirname "$0")" && pwd)
g++ -std=c++17 -O1 -I$HOME/.local/include "$D/objid.cpp" -o "$1" -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread
