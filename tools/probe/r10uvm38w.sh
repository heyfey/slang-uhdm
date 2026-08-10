#!/bin/bash
# r10uvm38w.sh <sweep-workdir> — BINDWRONG, the residue `r10uvm28m.sh` CANNOT
# SEE.  That metric classifies each reference as bound-or-bare and counts the
# disagreements; a reference BOTH sides bind, to DIFFERENT declarations, is
# invisible to it — and uhdm-cmp descends `Actual_group` and compares the
# target's VpiName, so those are real differences.  Measured on SeqDriver at
# pass 38: 180 of them in the `method_func_call/hier_path` family alone (golden
# binds the hier_path BASE's formal where we bind the argument's own name).
#
#   R10G=<r10uvm28g build> tools/probe/r10uvm38w.sh /tmp/xw
set -u
SW=${1:?sweep workdir}
V=${R10G:?set R10G to an r10uvm28g build}
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$V" "$G" > /tmp/r10uvm38w_g.txt 2>/dev/null
  "$V" "$D/slang.uhdm" > /tmp/r10uvm38w_o.txt 2>/dev/null
  n=$(python3 - /tmp/r10uvm38w_g.txt /tmp/r10uvm38w_o.txt <<'EOF'
import sys
def load(p):
    d = {}
    for l in open(p):
        l = l.rstrip('\n')
        if ' -> ' not in l:
            continue
        k, rest = l.rsplit(' -> ', 1)
        d.setdefault(k, set()).add(rest.split(' @ ', 1)[0])
    return d
g = load(sys.argv[1]); o = load(sys.argv[2])
n = 0
for k in set(g) & set(o):
    if g[k] == {'-'} or o[k] == {'-'}:
        continue          # bound-vs-bare is r10uvm28m's job
    if g[k] != o[k]:
        n += 1
print(n)
EOF
)
  echo "$T wrong=$n"
  TOT=$((TOT + n))
done
echo "BINDWRONG=$TOT"
