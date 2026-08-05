#!/bin/bash
# build a probe: r10earl6build.sh <name-without-ext>
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_50bba4e3-70a-1
g++ -std=c++20 -O1 "$W/tools/probe/$1.cpp" -o "/tmp/$1" \
    -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
    "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
echo "rc=$? -> /tmp/$1"
