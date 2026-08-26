#!/usr/bin/env python3
"""r10earl96 -- MEASUREMENT ONLY.  Multiset join of two ct96cen censuses.
KEY = fields 1..4, PAYLOAD = field 5.  Keys collide, so both sides are counted
as MULTISETS (a last-writer dict silently drops rows)."""
import sys, collections
def load(p):
    d = collections.defaultdict(collections.Counter)
    with open(p) as f:
        for ln in f:
            ln = ln.rstrip('\n')
            if not ln: continue
            parts = ln.split('\t')
            key = '\t'.join(parts[:4]); pay = parts[4] if len(parts) > 4 else ''
            d[key][pay] += 1
    return d
g = load(sys.argv[1]); o = load(sys.argv[2])
same = moved = gonly = oonly = 0
mv = []; go = []; oo = []
for k in set(g) | set(o):
    gc = g.get(k, collections.Counter()); oc = o.get(k, collections.Counter())
    inter = gc & oc
    same += sum(inter.values())
    gr = gc - inter; orr = oc - inter
    n = min(sum(gr.values()), sum(orr.values()))
    moved += n
    if n:
        mv.append((k, sorted(gr.items()), sorted(orr.items())))
    if sum(gr.values()) > n:
        gonly += sum(gr.values()) - n; go.append((k, sorted(gr.items())))
    if sum(orr.values()) > n:
        oonly += sum(orr.values()) - n; oo.append((k, sorted(orr.items())))
print('BOTH-SAME %d  MOVED-WRONG %d  GOLDEN-ONLY %d  OURS-ONLY %d' % (same, moved, gonly, oonly))
lim = int(sys.argv[3]) if len(sys.argv) > 3 else 40
for k, a, b in sorted(mv)[:lim]: print('MOVED  ', k, ' G', a, ' O', b)
for k, a in sorted(go)[:lim]:    print('GONLY  ', k, ' G', a)
for k, a in sorted(oo)[:lim]:    print('OONLY  ', k, ' O', a)
