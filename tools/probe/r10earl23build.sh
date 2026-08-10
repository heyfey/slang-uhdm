#!/bin/bash
# build a probe into /tmp/r10e23_<suffix>: r10earl23build.sh <name> <suffix>
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_8e1be37e-85d-1
g++ -std=c++20 -O1 "$W/tools/probe/$1.cpp" -o "/tmp/r10e23_$2" \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> /tmp/r10e23_$2"
