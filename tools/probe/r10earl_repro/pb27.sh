#!/bin/bash
# pb26.sh -- build the three generic probes this pass needs, under the
# /tmp/r10e27_* names the pass-26 drivers expect.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_469c0e7a-755-1
for p in 17c 22a 23a 2h; do
  g++ -std=c++20 -O1 "$W/tools/probe/r10earl$p.cpp" -o "/tmp/r10e27_$p" \
      -I"$HOME/.local/include" "$HOME/.local/lib64/libuhdm.a" \
      "$HOME/.local/lib64/libcapnp.a" "$HOME/.local/lib64/libkj.a" -lpthread
  echo "r10earl$p rc=$? -> /tmp/r10e27_$p"
done
