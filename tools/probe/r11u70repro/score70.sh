#!/bin/bash
# r11u70 GRID SCORER — per arm, per cell (listing|holder|name), joins the
# golden, pristine and law shape-lister lines and reports one of:
#   SAME   golden == pristine == law           (the arm was already right)
#   TO     pristine != golden, law == golden   (the law moved it TO golden)
#   AWAY   pristine == golden, law != golden   (a REGRESSION)
#   STILL  pristine != golden, law == pristine (unmoved, still wrong)
#   MOVED  pristine != golden, law != pristine, law != golden (moved, wrong)
#   G-ONLY the arm has no OUR side (compile failed) — golden text only
# usage: score70.sh <armname> ...
set -u
cd "$(dirname "$0")"
for n in "$@"; do
  if [ ! -s "pris/$n.dump" ] || [ ! -s "law/$n.dump" ]; then
    echo "$n  G-ONLY (our compile produced no database)"
    continue
  fi
  python3 shape70.py --all --nets "gold/$n.dump" > /tmp/r11u70_s_g.$$ 2>&1
  python3 shape70.py --all --nets "pris/$n.dump" > /tmp/r11u70_s_p.$$ 2>&1
  python3 shape70.py --all --nets "law/$n.dump"  > /tmp/r11u70_s_l.$$ 2>&1
  python3 - "$n" /tmp/r11u70_s_g.$$ /tmp/r11u70_s_p.$$ /tmp/r11u70_s_l.$$ <<'PY'
import sys
arm, gp, pp, lp = sys.argv[1:5]
def load(p):
    d = {}
    for ln in open(p, errors='replace'):
        ln = ln.rstrip('\n')
        if ln.count('|') < 3: continue
        a, b, c, rest = ln.split('|', 3)
        d[(a, b, c)] = rest
    return d
g, p, l = load(gp), load(pp), load(lp)
for k in sorted(set(g) | set(p) | set(l)):
    gv, pv, lv = g.get(k), p.get(k), l.get(k)
    if gv == pv == lv:   v = 'SAME'
    elif pv != gv and lv == gv: v = 'TO'
    elif pv == gv and lv != gv: v = 'AWAY'
    elif pv != gv and lv == pv: v = 'STILL'
    else: v = 'MOVED'
    print('%-5s %-6s %s' % (arm, v, '|'.join(k)))
    if v in ('AWAY', 'MOVED', 'STILL'):
        print('        G %s' % gv)
        print('        P %s' % pv)
        print('        L %s' % lv)
PY
  rm -f /tmp/r11u70_s_g.$$ /tmp/r11u70_s_p.$$ /tmp/r11u70_s_l.$$
done
