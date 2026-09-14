#!/bin/bash
# r11u31 TO-GOLDEN / AWAY-GOLDEN census for ONE mover row.
# Multiset (sort|uniq -c) of normalised uhdm-dump lines, three ways:
#   G = golden, P = pristine ours, Q = patched ours.
# For every distinct line L:  gain = min(|Q|,|G|) - min(|P|,|G|)   (toward golden)
#                             noise= max(0,|Q|-|G|) - max(0,|P|-|G|) (away)
# TO-GOLDEN = sum of positive gain; REGRESSED = sum of negative gain;
# AWAY-GOLDEN = sum of positive noise.  A census with all three zero is a
# no-op; a positive control (below) proves the instrument can see.
set -u
PW=${1:?pristine workdir}; QW=${2:?patched workdir}; M=${3:?mode}; T=${4:?test}
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
one() { d=$(ls -d "$1/$3/$4"-*/ | head -1); f=$2
        case $f in gold) g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt"|head -1)/golden.uhdm; u=$g;;
                   *)    u="$d/slang.uhdm";; esac
        "$DUMP" "$u" 2>&1 | sed -e "s#$d##g" -e 's#/home/heyfey/[^ ,)]*##g'; }
one "$PW" gold "$M" "$T" | sort > /tmp/r11u31_tg_G.$$
one "$PW" ours "$M" "$T" | sort > /tmp/r11u31_tg_P.$$
one "$QW" ours "$M" "$T" | sort > /tmp/r11u31_tg_Q.$$
python3 - "$T" "$M" /tmp/r11u31_tg_G.$$ /tmp/r11u31_tg_P.$$ /tmp/r11u31_tg_Q.$$ <<'PY'
import sys, collections
t,m,g,p,q = sys.argv[1:6]
C=lambda f: collections.Counter(open(f).read().splitlines())
G,P,Q=C(g),C(p),C(q)
keys=set(G)|set(P)|set(Q)
to=reg=away=0
for k in keys:
    gg,pp,qq=G[k],P[k],Q[k]
    gain=min(qq,gg)-min(pp,gg)
    if gain>0: to+=gain
    elif gain<0: reg+=-gain
    n=max(0,qq-gg)-max(0,pp-gg)
    if n>0: away+=n
print("%-32s %-9s TO-GOLDEN %4d  REGRESSED %4d  AWAY-GOLDEN %4d" % (t,m,to,reg,away))
PY
rm -f /tmp/r11u31_tg_G.$$ /tmp/r11u31_tg_P.$$ /tmp/r11u31_tg_Q.$$
