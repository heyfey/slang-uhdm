#!/usr/bin/env python3
"""v11u66 VERIFIER ORDINAL SCORER — independent of the implementer's cmp66.py.

Keys every op75 operand by (section, Lhs parameter name, operand ORDINAL) via
the committed shape lister, and scores pristine and law against golden twice:
FULL (size+constType+value) and ENC (constType+value).
  TO           pristine wrong, law == golden
  AWAY         pristine == golden, law wrong        <-- the regression class
  MOVED-WRONG  law != pristine and law != golden and pristine == golden
  STILL        both wrong, unchanged
  WRONG2       both wrong, but law changed the cell
  SAME         all three agree / law == pristine and both wrong is STILL
usage: ord66v.py <g.dump> <pris.dump> <law.dump> <arm>
"""
import sys, re, importlib.util
spec = importlib.util.spec_from_file_location('shape', '/tmp/v11u66_grid/shape.py')
shape = importlib.util.module_from_spec(spec); spec.loader.exec_module(shape)

def cells(path):
    out = {}
    seen = {}
    for sect, name, loc, d in shape.parse(path):
        if not d.startswith('op='):
            continue
        m = re.search(r'ops=\[(.*)\]$', d)
        if not m:
            continue
        ops = m.group(1).split() if m.group(1) else []
        k0 = (sect, name, loc)
        n = seen.get(k0, 0); seen[k0] = n + 1
        for i, o in enumerate(ops):
            out[(sect, name, loc, n, i)] = o
    return out

def enc(o):
    m = re.match(r'const/([^@]*)@([^=]*)=(.*)$', o)
    return ('const', m.group(2), m.group(3)) if m else (o,)

def full(o):
    m = re.match(r'const/([^@]*)@([^=]*)=(.*)$', o)
    return ('const', m.group(1), m.group(2), m.group(3)) if m else (o,)

g, p, l, arm = sys.argv[1:5]
G, P, L = cells(g), cells(p), cells(l)
if not G:
    print('FATAL: no op75 row in golden'); sys.exit(4)
res = {}
for mode, f in (('FULL', full), ('ENC', enc)):
    to = away = mw = still = same = wrong2 = 0
    for k in sorted(set(G) | set(P) | set(L)):
        gv = G.get(k, '<absent>'); pv = P.get(k, '<absent>'); lv = L.get(k, '<absent>')
        gg, pp, ll = f(gv), f(pv), f(lv)
        if pp == gg and ll == gg: same += 1
        elif pp == gg and ll != gg:
            away += 1; mw += 1
            print('  *** AWAY %-14s %-26s op%d  G=%s P=%s L=%s' % (k[0], k[1], k[4], gv, pv, lv))
        elif pp != gg and ll == gg:
            to += 1
            if mode == 'ENC':
                print('  TO   %-14s %-26s op%d  G=%s P=%s L=%s' % (k[0], k[1], k[4], gv, pv, lv))
        elif pp == ll: still += 1
        else:
            wrong2 += 1
            if mode == 'ENC':
                print('  W2   %-14s %-26s op%d  G=%s P=%s L=%s' % (k[0], k[1], k[4], gv, pv, lv))
    res[mode] = (to, away, mw, still, same, wrong2)
for mode in ('FULL', 'ENC'):
    to, away, mw, still, same, w2 = res[mode]
    print('ARM %-14s %-4s TO=%d AWAY=%d MOVED-WRONG=%d STILL=%d SAME=%d WRONG2=%d'
          % (arm, mode, to, away, mw, still, same, w2))
