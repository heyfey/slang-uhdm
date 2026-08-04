#!/bin/bash
# r10uvm9erun: hier_path element census (r10uvm9e) on both sides of a pair.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e4a1375e-b25-1
D=/tmp/r10uvm9_tw/${2:-default}/$1
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $D/cmds.txt | head -1)/golden.uhdm
S=$D/slang.uhdm
g++ -std=c++17 -O1 -I$HOME/.local/include $W/tools/probe/r10uvm9e.cpp \
  -o /tmp/r10uvm9_e -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
/tmp/r10uvm9_e "$G" > /tmp/r10uvm9_e_g.txt 2>&1
/tmp/r10uvm9_e "$S" > /tmp/r10uvm9_e_s.txt 2>&1
wc -l /tmp/r10uvm9_e_g.txt /tmp/r10uvm9_e_s.txt
