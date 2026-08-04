#!/bin/bash
# r10uvm9a: dump ONE subroutine body from both sides of a UVM-4 pair.
#   r10uvm9a.sh <Test-hash> <all|top> <pkg> <sub> [class] [mode]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e4a1375e-b25-1
D=/tmp/r10uvm9_tw/${6:-default}/$1
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $D/cmds.txt | head -1)/golden.uhdm
S=$D/slang.uhdm
[ -x /tmp/r10uvm9_a ] || g++ -std=c++17 -O1 -I$HOME/.local/include \
  $W/tools/probe/r10uvm8a.cpp -o /tmp/r10uvm9_a \
  -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
/tmp/r10uvm9_a "$G" "$2" "$3" "$4" $5 > /tmp/r10uvm9_a_g.txt 2>&1
/tmp/r10uvm9_a "$S" "$2" "$3" "$4" $5 > /tmp/r10uvm9_a_s.txt 2>&1
wc -l /tmp/r10uvm9_a_g.txt /tmp/r10uvm9_a_s.txt
