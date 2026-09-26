#!/bin/bash
# cc.sh <tool.cpp> <out>: compile one of this directory's UHDM census tools against the installed UHDM (~/.local).
L=$HOME/.local/lib64; [ -f $L/libuhdm.a ] || L=$HOME/.local/lib
C=$HOME/.local/lib64; [ -f $C/libcapnp.a ] || C=$HOME/.local/lib
g++ -std=c++17 -O1 -I$HOME/.local/include -I$HOME/.local/include/uhdm "$1" $L/libuhdm.a $C/libcapnp.a $C/libkj.a -lpthread -o "$2"
