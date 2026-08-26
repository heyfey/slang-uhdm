#!/usr/bin/env python3
"""r10v152 (verifier) census — INDEPENDENT of the implementer's scorer.
Key = (reference LINE, reference COL).  Payload = multiset of
"kind|targetname|line:col" for every vpiActual the reference carries.
LHS is ALWAYS golden.  usage: vcen.py <g.dump> <pris.dump> <patc.dump>
"""
import sys, re, collections
ref_re = re.compile(r'^(\s*)\\_(ref_obj|hier_path): \(([^)]*)\)(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?')
act_re = re.compile(r'^(\s*)\|vpiActual:')
obj_re = re.compile(r'^(\s*)\\_([a-z_]+): (?:\(([^)]*)\))?(?:, line:(\d+):(\d+))?')

def scan(path):
    d = collections.defaultdict(collections.Counter)
    lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
    cur = None
    for i, l in enumerate(lines):
        m = ref_re.match(l)
        if m:
            cur = (m.group(3), m.group(4), m.group(5), len(m.group(1)))
            continue
        m = act_re.match(l)
        if m and cur and cur[1]:
            if len(m.group(1)) != cur[3] + 2:
                continue
            m2 = obj_re.match(lines[i+1]) if i+1 < len(lines) else None
            if m2:
                d[(int(cur[1]), int(cur[2]), cur[0].split('::')[-1].split('.')[-1])][
                    '%s|%s|%s:%s' % (m2.group(2), m2.group(3), m2.group(4), m2.group(5))] += 1
    return d

g, p, q = scan(sys.argv[1]), scan(sys.argv[2]), scan(sys.argv[3])
c = collections.Counter()
for k in sorted(set(g) | set(p) | set(q)):
    gv, pv, qv = g.get(k), p.get(k), q.get(k)
    if gv is None:
        c['ONLY-OURS-pris'] += (pv is not None); c['ONLY-OURS-patc'] += (qv is not None)
        if (pv is None) != (qv is None):
            print('ONLY-OURS-CHANGED', k, 'P=', dict(pv or {}), 'Q=', dict(qv or {}))
        continue
    if pv is None and qv is None:
        c['ONLY-GOLDEN-pris'] += 1; c['ONLY-GOLDEN-patc'] += 1; continue
    pr, qr = (pv == gv), (qv == gv)
    if pr and qr: c['RIGHT->RIGHT'] += 1
    elif not pr and qr:
        c['WRONG->RIGHT'] += 1; print('W->R ', k, 'G=', dict(gv), 'P=', dict(pv or {}))
    elif pr and not qr:
        c['RIGHT->WRONG'] += 1; print('R->W ', k, 'G=', dict(gv), 'Q=', dict(qv or {}))
    else:
        if pv == qv: c['WRONG->WRONG(unmoved)'] += 1
        else:
            c['WRONG->WRONG(MOVED)'] += 1
            print('WW-MOVED', k, 'G=', dict(gv), 'P=', dict(pv or {}), 'Q=', dict(qv or {}))
for kk in ('RIGHT->RIGHT','WRONG->RIGHT','RIGHT->WRONG','WRONG->WRONG(unmoved)',
           'WRONG->WRONG(MOVED)','ONLY-GOLDEN-pris','ONLY-GOLDEN-patc',
           'ONLY-OURS-pris','ONLY-OURS-patc'):
    print('%-24s %d' % (kk, c[kk]))
