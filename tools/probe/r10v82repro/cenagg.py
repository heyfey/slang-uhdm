#!/usr/bin/env python3
"""v82 verifier — corpus aggregate over rngcen82 censuses.
For each test: key = (span-without-file, slot); payload = the judge-visible
payload string.  Reports the whole-payload 3-way AND the SLOT-level
LOST/GAINED (multiset intersection with golden), which the span-level verdict
can mask.  Also counts SIZE-ONLY divergences remaining in each state.
usage: cenagg.py <censdir_pris> <censdir_patched>
"""
import sys, os, collections, re
FIELD = re.compile(r'(\w+)=(\S+)')

def parse(fn):
    rows = collections.Counter()
    try: f = open(fn, errors='replace')
    except OSError: return rows
    for l in f:
        if not l.startswith('RNG '): continue
        try: head, pay = l.rstrip('\n').split(' || ', 1)
        except ValueError: continue
        parts = head.split(' ')
        slot = parts[-2][2:]; span = parts[-1][3:]
        col = span.find(':'); span = span[col+1:]
        rows[((span, slot), pay)] += 1
    return rows

def bykey(rows):
    d = collections.defaultdict(collections.Counter)
    for (k, pay), n in rows.items(): d[k][pay] += n
    return d

def fields(p): return dict(FIELD.findall(p))

def sizeonly(gl, ol):
    if len(gl) != len(ol) or not gl: return False
    for a, b in zip(sorted(gl), sorted(ol)):
        fa, fb = fields(a), fields(b)
        if set(fa) != set(fb): return False
        if [k for k in fa if fa[k] != fb[k]] != ['sz']: return False
    return True

PD, QD = sys.argv[1], sys.argv[2]
t = collections.Counter(); lost = collections.Counter(); gained = 0
so_p = so_q = 0; keys = 0
for fn in sorted(os.listdir(PD)):
    if not fn.endswith('.ours.cen'): continue
    stem = fn[:-len('.ours.cen')]
    gf = os.path.join(PD, stem + '.gold.cen')
    pf = os.path.join(PD, fn); qf = os.path.join(QD, fn)
    if not (os.path.exists(gf) and os.path.exists(qf)): continue
    g, p, q = bykey(parse(gf)), bykey(parse(pf)), bykey(parse(qf))
    for k in set(g) | set(p) | set(q):
        keys += 1
        gp, pp, qp = g.get(k, collections.Counter()), p.get(k, collections.Counter()), q.get(k, collections.Counter())
        if sizeonly(sorted((gp-pp).elements()), sorted((pp-gp).elements())): so_p += 1
        if sizeonly(sorted((gp-qp).elements()), sorted((qp-gp).elements())): so_q += 1
        if pp == qp:
            t['UNMOVED-RIGHT' if qp == gp else 'UNMOVED-WRONG'] += 1
        elif qp == gp: t['TO-GOLDEN'] += 1
        elif pp == gp:
            t['AWAY-GOLDEN'] += 1
            print(f"AWAY\t{stem}\t{k}\tG:{sorted(gp.elements())}\tP:{sorted(pp.elements())}\tQ:{sorted(qp.elements())}")
        else: t['MOVED-WRONG'] += 1
        rp, rq = gp & pp, gp & qp
        l, gn = rp - rq, rq - rp
        if l:
            lost[stem] += sum(l.values())
            print(f"LOST-SLOT\t{stem}\t{k}\t{dict(l)}")
        gained += sum(gn.values())
print(f"# keys={keys} " + '  '.join(f'{k}={v}' for k, v in sorted(t.items())))
print(f"# SIZE-ONLY keys: pristine={so_p} patched={so_q}")
print(f"# SLOTS lost={sum(lost.values())} gained={gained}")
