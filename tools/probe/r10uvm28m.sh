#!/bin/bash
# r10uvm28m.sh <sweep-workdir> — THE REFERENCE-BINDING metric for the UVM-4.
#
# `Actual_group` is one pointer per reference, invisible in every shape census
# this campaign has built, and `uhdm-cmp` descends into it, so a wrong binding
# shows up only as an unrelated-looking deep pair ("L <null>  R string_var
# 'v'").  This diffs the r10uvm28g census key by key — key = view + enclosing
# task_func + reference kind/name/line:col — and reports, per test, how many
# references we bind that golden leaves bare (EXTRA) and how many golden binds
# that we leave bare (MISS).
#
#   R10G=<r10uvm28g build> tools/probe/r10uvm28m.sh /tmp/xw
set -u
SW=${1:?sweep workdir}
V=${R10G:?set R10G to an r10uvm28g build}
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$V" "$G" > /tmp/r10uvm28m_g.txt 2>/dev/null
  "$V" "$D/slang.uhdm" > /tmp/r10uvm28m_o.txt 2>/dev/null
  read -r e m < <(python3 - /tmp/r10uvm28m_g.txt /tmp/r10uvm28m_o.txt <<'EOF'
import sys
def load(p):
    d = {}
    for l in open(p):
        l = l.rstrip('\n')
        if ' -> ' not in l:
            continue
        k, rest = l.rsplit(' -> ', 1)
        act = rest.split(' @ ', 1)[0]
        d.setdefault(k, set()).add(act)
    return d
g = load(sys.argv[1]); o = load(sys.argv[2])
e = m = 0
for k in set(g) & set(o):
    gb = g[k] != {'-'}; ob = o[k] != {'-'}
    if gb == ob:
        continue
    if ob:
        e += 1
    else:
        m += 1
print(e, m)
EOF
)
  echo "$T extra=$e miss=$m"
  TOT=$((TOT + e + m))
done
echo "BINDTOTAL=$TOT"
