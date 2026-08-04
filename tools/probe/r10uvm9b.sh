#!/bin/bash
# r10uvm9b: body-differ (r10uvm7b) histogram over one of the UVM-4 pairs.
#   r10uvm9b.sh <TestName-hash> [mode] [rows|part]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e4a1375e-b25-1
D=/tmp/r10uvm9_tw/${2:-default}/$1
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $D/cmds.txt | head -1)/golden.uhdm
S=$D/slang.uhdm
[ -x /tmp/r10uvm9_b ] || g++ -std=c++17 -O1 -I$HOME/.local/include \
  $W/tools/probe/r10uvm7b.cpp -o /tmp/r10uvm9_b \
  -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt || exit 1
timeout 3600 /tmp/r10uvm9_b "$G" "$S" ${3:-part} > /tmp/r10uvm9_b_$1_${2:-default}.txt 2>&1
echo "rc=$? lines=$(wc -l < /tmp/r10uvm9_b_$1_${2:-default}.txt)"
tail -30 /tmp/r10uvm9_b_$1_${2:-default}.txt
