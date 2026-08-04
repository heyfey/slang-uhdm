#!/bin/bash
# r10uvm9crun: role-aware reference census (r10uvm9c) on both sides of a pair.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e4a1375e-b25-1
D=/tmp/r10uvm9_tw/${2:-default}/$1
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $D/cmds.txt | head -1)/golden.uhdm
S=$D/slang.uhdm
/tmp/r10uvm9_c "$G" > /tmp/r10uvm9_c_g.txt 2>&1
/tmp/r10uvm9_c "$S" > /tmp/r10uvm9_c_s.txt 2>&1
wc -l /tmp/r10uvm9_c_g.txt /tmp/r10uvm9_c_s.txt
