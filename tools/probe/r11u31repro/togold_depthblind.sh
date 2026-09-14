#!/bin/bash
# Same census, DEPTH-BLIND (leading whitespace stripped): separates a genuine
# shape difference from a printer artifact of object SHARING (golden shares one
# range across its three wrappers, so uhdm-dump abbreviates the repeats; we
# clone, so each prints in full at its own depth).
set -u
PW=$1; QW=$2; M=$3; T=$4
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
one() { d=$(ls -d "$1/$3/$4"-*/ | head -1)
        case $2 in gold) u=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt"|head -1)/golden.uhdm;;
                   *) u="$d/slang.uhdm";; esac
        "$DUMP" "$u" 2>&1 | sed -e "s#$d##g" -e 's#/home/heyfey/[^ ,)]*##g' -e 's/^[[:space:]]*//'; }
one "$PW" gold "$M" "$T" | sort > /tmp/r11u31_t2_G.$$
one "$PW" ours "$M" "$T" | sort > /tmp/r11u31_t2_P.$$
one "$QW" ours "$M" "$T" | sort > /tmp/r11u31_t2_Q.$$
python3 - "$T" "$M" /tmp/r11u31_t2_G.$$ /tmp/r11u31_t2_P.$$ /tmp/r11u31_t2_Q.$$ <<'PY'
import sys, collections
t,m,g,p,q = sys.argv[1:6]
C=lambda f: collections.Counter(open(f).read().splitlines())
G,P,Q=C(g),C(p),C(q)
to=reg=away=0; awl=[]
for k in set(G)|set(P)|set(Q):
    gain=min(Q[k],G[k])-min(P[k],G[k])
    to+= gain if gain>0 else 0
    reg+= -gain if gain<0 else 0
    n=max(0,Q[k]-G[k])-max(0,P[k]-G[k])
    if n>0: away+=n; awl.append((n,k))
print("%-32s %-9s DEPTH-BLIND  TO-GOLDEN %4d  REGRESSED %4d  AWAY-GOLDEN %4d" % (t,m,to,reg,away))
for n,k in sorted(awl, reverse=True): print("      away %3d : %s" % (n,k))
PY
rm -f /tmp/r11u31_t2_G.$$ /tmp/r11u31_t2_P.$$ /tmp/r11u31_t2_Q.$$
