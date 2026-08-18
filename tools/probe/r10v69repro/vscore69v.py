#!/usr/bin/env python3
# r10v69 VERIFIER scorer — judge-faithful, NO-SPAN.
# hier_path::Compare = Path_elems, Root_value, VpiName.  Compare NEVER reads a
# span, a location or a fullname, so the ELEMS payload used to decide
# "elements already differ" must carry NO span and NO loc (earl60's lesson:
# a span-carrying payload hides a real name flip inside STILL-WRONG).
# Span PRESENCE is scored SEPARATELY.
import collections, re, sys
SPAN = re.compile(r',?span=[^,}|; ]*')
LOC  = re.compile(r',?loc=[01]')
def load(p):
    d = collections.defaultdict(list)
    try: fh = open(p)
    except OSError: return d
    for l in fh:
        f = l.rstrip('\n').split(' ')
        if f[0] != 'HP': continue
        key = (f[1], f[2], f[3], f[4])
        kv = {}
        for x in f[5:]:
            if '=' in x:
                k, v = x.split('=', 1); kv.setdefault(k, v)
        elems = f[-1]
        judge = LOC.sub('', SPAN.sub('', elems))       # NO span, NO loc
        locs  = ','.join(re.findall(r'loc=([01])', elems)) + '|' + kv.get('loc','?')
        d[key].append((judge, kv.get('name'), locs, elems))
    return d
g, P, Q = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
tag = sys.argv[4] if len(sys.argv) > 4 else ''
b = collections.Counter(); sp = collections.Counter(); rows = []
for k in sorted(set(g) | set(P) | set(Q)):
    G, O, R = sorted(g.get(k, [])), sorted(P.get(k, [])), sorted(Q.get(k, []))
    n = max(len(G), len(O), len(R))
    pad = ('<none>', None, '', '')
    G += [pad]*(n-len(G)); O += [pad]*(n-len(O)); R += [pad]*(n-len(R))
    for i in range(n):
        gd, pr, pa = G[i], O[i], R[i]
        def v(x):
            if x[1] is None or gd[1] is None: return 'ABSENT'
            if x[0] != gd[0]: return 'ELEMS-DIFFER'
            return 'EQ' if x[1] == gd[1] else 'NAME-DIFFERS'
        vp, vq = v(pr), v(pa)
        if vp == vq: c = 'STILL-RIGHT' if vq == 'EQ' else 'STILL-WRONG(%s)' % vq
        elif vq == 'EQ': c = 'TO-GOLDEN'
        elif vp == 'EQ': c = 'AWAY-GOLDEN'
        else: c = 'MOVED-WRONG(%s->%s)' % (vp, vq)
        b[c] += 1
        # NAME-ONLY view: ignore elems entirely (the strictest reading)
        if pr[1] != pa[1]:
            if pa[1] == gd[1]: sp['NAME-ONLY:TO-GOLDEN'] += 1
            elif pr[1] == gd[1]: sp['NAME-ONLY:AWAY-GOLDEN'] += 1; rows.append(('NAMEONLY-AWAY',k,gd[1],pr[1],pa[1]))
            else: sp['NAME-ONLY:MOVED-WRONG'] += 1; rows.append(('NAMEONLY-MW',k,gd[1],pr[1],pa[1]))
        if pr[2] != pa[2]: sp['SPAN-PRESENCE-CHANGED'] += 1
        if c.startswith('AWAY') or c.startswith('MOVED'):
            rows.append((c, k, gd[1], pr[1], pa[1]))
print('%s cells %d %s' % (tag, sum(b.values()), dict(b)))
if sp: print('   %s aux %s' % (tag, dict(sp)))
for r in rows[:40]:
    print('   ', r[0], r[1][0], r[1][2], r[1][3], '| G', r[2], '| PRIS', r[3], '| PAT', r[4])
