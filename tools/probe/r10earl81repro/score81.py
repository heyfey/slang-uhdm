#!/usr/bin/env python3
"""r10earl81 — 2-way (golden vs one binary) and 3-way (golden / pristine /
patched) multiset scorer for selcen81 rows.

MEASUREMENT ONLY.  The judge is uhdm-cmp.

KEY   = chain + select kind + slot + base name  (NO span: our rvalue-select
        spans differ from golden's by a landed law, and keying on them would
        manufacture phantom AWAY-GOLDEN cells — RESUME §9's census traps.)
PAYLOAD = only fields the generated Compare reads (plus VpiValue, which must
        follow the const type).

Rows are joined as MULTISETS per key (keys collide by construction: one
`design` reaches the same object twice, and a module instantiated N times
gives N identical rows) — never a last-writer dict.

usage: score81.py golden.cen ours.cen              -> 2-way DIFF report
       score81.py golden.cen pris.cen patched.cen  -> 3-way TO-GOLDEN/AWAY/MOVED-WRONG
options: --filter SUBSTR   only rows whose KEY contains SUBSTR
         --show N          print up to N differing cells
"""
import sys, collections

def load(p, filt=None):
    d = collections.defaultdict(collections.Counter)
    with open(p) as f:
        for ln in f:
            if not ln.startswith('SEL '):
                continue
            head, _, pay = ln.rstrip('\n').partition(' || ')
            # drop the span field from the KEY
            parts = [x for x in head.split(' ') if not x.startswith('sp=')]
            key = ' '.join(parts)
            if filt and filt not in key:
                continue
            d[key][pay] += 1
    return d

def diff(a, b):
    """cells where the two multisets disagree; returns (key, onlyA, onlyB)"""
    out = []
    for k in set(a) | set(b):
        ca, cb = a.get(k, collections.Counter()), b.get(k, collections.Counter())
        if ca == cb:
            continue
        oa, ob = ca - cb, cb - ca
        out.append((k, oa, ob))
    return out

def main():
    args = [x for x in sys.argv[1:]]
    filt = None; show = 12
    while '--filter' in args:
        i = args.index('--filter'); filt = args[i+1]; del args[i:i+2]
    while '--show' in args:
        i = args.index('--show'); show = int(args[i+1]); del args[i:i+2]
    G = load(args[0], filt)
    if len(args) == 2:
        O = load(args[1], filt)
        dd = diff(G, O)
        ncells = sum(sum(c.values()) for c in G.values())
        ndiff = sum(sum(oa.values()) + sum(ob.values()) for _, oa, ob in dd)
        print(f'golden rows {ncells}  ours rows {sum(sum(c.values()) for c in O.values())}'
              f'  differing KEYS {len(dd)}  differing row-instances {ndiff}')
        for k, oa, ob in sorted(dd)[:show]:
            print('KEY', k)
            for p, n in oa.items(): print('   G x%d %s' % (n, p))
            for p, n in ob.items(): print('   O x%d %s' % (n, p))
        return
    P = load(args[1], filt); Q = load(args[2], filt)
    still_right = still_wrong = to_g = away = moved_wrong = 0
    for k in set(G) | set(P) | set(Q):
        g = G.get(k, collections.Counter())
        p = P.get(k, collections.Counter())
        q = Q.get(k, collections.Counter())
        if p == q:
            if g == p: still_right += sum(g.values())
            else:      still_wrong += max(sum(g.values()), sum(p.values()))
            continue
        # the key MOVED — classify each moved row-instance
        gone = p - q      # payloads pristine had and patched does not
        came = q - p      # payloads patched has and pristine did not
        for pay, n in came.items():
            if g[pay] > 0: to_g += n
            else:          moved_wrong += n
        for pay, n in gone.items():
            if g[pay] > 0: away += n
    print(f'cells(golden row-instances) {sum(sum(c.values()) for c in G.values())}  '
          f'STILL-RIGHT {still_right}  STILL-WRONG {still_wrong}  '
          f'TO-GOLDEN {to_g}  AWAY-GOLDEN {away}  MOVED-WRONG {moved_wrong}')
    if show:
        n = 0
        for k in sorted(set(P) | set(Q)):
            if P.get(k, collections.Counter()) == Q.get(k, collections.Counter()):
                continue
            n += 1
            if n > show: break
            print('MOVED', k)
            print('   G', dict(G.get(k, {})))
            print('   P', dict(P.get(k, {})))
            print('   Q', dict(Q.get(k, {})))

main()
