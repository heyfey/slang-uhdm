#!/bin/bash
# r11u236repro: build the two decode helpers (both refuse to run without $FENCED or on a path naming a fenced test).
# usage: cc_tools.sh <out dir>
D=$(cd "$(dirname "$0")" && pwd); O=${1:?out dir}
g++ -std=c++17 -O1 -I$HOME/.local/include "$D/objid236.cpp" -o "$O/objid236" -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread
g++ -std=c++17 -O2 -I$HOME/.local/include "$D/strictid236.cpp" -o "$O/strictid236" -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread
