#!/usr/bin/env python3
"""r11u24 — DIRECTIONAL census over the keyed param_assign Rhs cells.

    dircen24.py <gold.dump> <pris.dump> <pat.dump>

Classifies every key that exists in any of the three:
  SAME          judge-visible cells equal on both binaries and equal to golden
  TO-GOLDEN     pristine != golden, patched == golden
  AWAY-GOLDEN   pristine == golden, patched != golden        <- must be 0
  MOVED-WRONG   pristine != patched, both != golden          <- must be 0
  STILL-WRONG   pristine == patched, both != golden
"""
import sys, importlib.util, os
spec = importlib.util.spec_from_file_location(
    'pacen24', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'pacen24.py'))
# pacen24 runs main() on import; read it as text and exec only the definitions
src = open(spec.origin).read().replace('\nmain()\n', '\n')
ns = {'__name__': 'pacen24'}
exec(compile(src, spec.origin, 'exec'), ns)
parse, KEYS = ns['parse'], ns['KEYS']

def j(c):
    return '<absent>' if c is None else ' '.join('%s=%s' % (k, c[k]) for k in KEYS)

g, p, q = parse(sys.argv[1]), parse(sys.argv[2]), parse(sys.argv[3])
cnt = {'SAME': 0, 'TO-GOLDEN': 0, 'AWAY-GOLDEN': 0, 'MOVED-WRONG': 0,
       'STILL-WRONG': 0}
for k in sorted(set(g) | set(p) | set(q)):
    gj, pj, qj = j(g.get(k)), j(p.get(k)), j(q.get(k))
    if pj == gj and qj == gj:
        tag = 'SAME'
    elif pj != gj and qj == gj:
        tag = 'TO-GOLDEN'
    elif pj == gj and qj != gj:
        tag = 'AWAY-GOLDEN'
    elif pj != qj:
        tag = 'MOVED-WRONG'
    else:
        tag = 'STILL-WRONG'
    cnt[tag] += 1
    if tag != 'SAME':
        print('%-12s %-12s %s\n     G %s\n     P %s\n     Q %s'
              % (tag, k[0], k[2], gj, pj, qj))
print('[S] ' + ' '.join('%s=%d' % (t, cnt[t]) for t in
                        ['SAME', 'TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG',
                         'STILL-WRONG']))
