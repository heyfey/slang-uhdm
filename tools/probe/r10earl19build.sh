#!/bin/bash
# build a probe: r10earl19build.sh <name-without-ext> [outname]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_cc163075-047-1
OUT=${2:-$1}
g++ -std=c++20 -O1 "$W/tools/probe/$1.cpp" -o "/tmp/r10e19_$OUT" \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> /tmp/r10e19_$OUT"
