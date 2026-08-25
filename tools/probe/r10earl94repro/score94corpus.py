#!/usr/bin/env python3
"""r10earl94 — score a corpus census: MULTISET join per (database,key), over
the whole fixed universe (keys collide; a last-writer dict drops rows).  Prints
the four buckets and, with --cells FILE, writes every MOVED-WRONG and one-sided
cell.  MEASUREMENT ONLY; the official uhdm-cmp is the judge."""
import sys, collections
def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln: continue
        tag, _, rest = ln.partition('\t')
        k, _, r2 = rest.partition(' => ')
        pay, _, n = r2.rpartition(' #')
        d[(tag, k)][pay] += int(n)
    return d
G, O = load(sys.argv[1]), load(sys.argv[2])
same = moved = gonly = oonly = 0
rows = []
for key, gp in G.items():
    op = O.get(key)
    gt = sum(gp.values())
    if op is None:
        gonly += gt
        rows.append(("GOLDEN-ONLY", key, dict(gp), {}))
        continue
    ot = sum(op.values())
    ident = sum(min(c, op.get(p, 0)) for p, c in gp.items())
    same += ident
    common = min(gt, ot)
    d = common - ident
    if d > 0:
        moved += d
        rows.append(("MOVED", key, dict(gp), dict(op)))
    if gt > ot:
        gonly += gt - ot
        rows.append(("GOLDEN-ONLY", key, dict(gp), dict(op)))
for key, op in O.items():
    if key not in G:
        oonly += sum(op.values())
        rows.append(("OURS-ONLY", key, {}, dict(op)))
    else:
        gt, ot = sum(G[key].values()), sum(op.values())
        if ot > gt:
            oonly += ot - gt
            rows.append(("OURS-ONLY", key, dict(G[key]), dict(op)))
print("BOTH-SAME %d  MOVED-WRONG %d  GOLDEN-ONLY %d  OURS-ONLY %d" % (same, moved, gonly, oonly))
fam = collections.Counter()
for (t, k), pc in G.items(): fam['G ' + k.split('|')[0]] += sum(pc.values())
for (t, k), pc in O.items(): fam['O ' + k.split('|')[0]] += sum(pc.values())
print("  families " + "  ".join("%s=%d" % (a, b) for a, b in sorted(fam.items())))
if '--cells' in sys.argv:
    out = sys.argv[sys.argv.index('--cells') + 1]
    with open(out, 'wt') as f:
        for kind, key, a, b in sorted(rows, key=lambda r: (r[0], r[1])):
            f.write("%s\t%s\t%s\tG=%s\tO=%s\n" % (kind, key[0], key[1], sorted(a.items()), sorted(b.items())))
