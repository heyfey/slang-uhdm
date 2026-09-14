#!/bin/bash
set -u
PW=$1; QW=$2; M=$3; T=$4
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
one() { d=$(ls -d "$1/$3/$4"-*/ | head -1)
        case $2 in gold) u=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt"|head -1)/golden.uhdm;;
                   *) u="$d/slang.uhdm";; esac
        "$DUMP" "$u" 2>&1 | sed -e "s#$d##g" -e 's#/home/heyfey/[^ ,)]*##g'; }
one "$PW" gold "$M" "$T" | sort > /tmp/r11u31_aw_G.$$
one "$PW" ours "$M" "$T" | sort > /tmp/r11u31_aw_P.$$
one "$QW" ours "$M" "$T" | sort > /tmp/r11u31_aw_Q.$$
python3 - "$T" "$M" /tmp/r11u31_aw_G.$$ /tmp/r11u31_aw_P.$$ /tmp/r11u31_aw_Q.$$ <<'PY'
import sys, collections
t,m,g,p,q = sys.argv[1:6]
C=lambda f: collections.Counter(open(f).read().splitlines())
G,P,Q=C(g),C(p),C(q)
print("== AWAY-GOLDEN lines, %s/%s  (count : line)" % (t,m))
for k in sorted(set(G)|set(P)|set(Q)):
    n=max(0,Q[k]-G[k])-max(0,P[k]-G[k])
    if n>0: print("%4d : %s" % (n,k))
PY
rm -f /tmp/r11u31_aw_G.$$ /tmp/r11u31_aw_P.$$ /tmp/r11u31_aw_Q.$$
