#!/usr/bin/env python3
# r10earl68 — THE GENVAR-READ CENSUS.  Joins two cen68 censuses as a MULTISET on
# the positional key (sec, instance path, site, route) and classifies every cell
# whose OUR-side object is a `ref_obj` naming a GENVAR of the design, by
#   (section, site kind, positional route tail = the POSITION,
#    the genvar's declaring loop, nesting depth) -> golden kind + judge fields.
# MEASUREMENT ONLY; the official uhdm-cmp stays the judge.
#   usage: gvcen68.py <golden.ex> <ours.ex> <gvnames,comma,sep> [--rows]
import sys, re
from collections import defaultdict, Counter
GV = set(sys.argv[3].split(','))
ROWS = '--rows' in sys.argv
def load(p):
    d = defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        d[' '.join(f[:5])].append(f[5:])
    return d
g, o = load(sys.argv[1]), load(sys.argv[2])
fam = Counter(); gk_by = defaultdict(Counter); rows = []
for k in set(g) | set(o):
    G, O = sorted(g.get(k, [])), sorted(o.get(k, []))
    n = max(len(G), len(O))
    G += [['<none>']] * (n - len(G)); O += [['<none>']] * (n - len(O))
    tag, sec, inst, site, path = k.split(' ')
    for i in range(n):
        gk, ok = G[i][0], O[i][0]
        if ok != 'ref_obj':
            continue
        nm = [x[5:] for x in O[i] if x.startswith('name=')]
        nm = nm[0] if nm else '-'
        if nm not in GV:
            continue
        if '[' not in inst:          # not inside any unrolled gen loop
            continue
        sk = site.split('_')[0]
        tail = re.sub(r'\[\d+\]', '[]', path.split('/')[-1])
        # golden payload, judge fields only
        if gk == 'constant':
            d = dict(x.split('=', 1) for x in G[i][1:] if '=' in x)
            pay = 'CONST ct=%s sz=%s val=%s ts=%s' % (
                d.get('ct'), d.get('sz'),
                re.sub(r':.*', ':N', d.get('val', '-')), d.get('ts'))
        elif gk == 'ref_obj':
            d = dict(x.split('=', 1) for x in G[i][1:] if '=' in x)
            pay = 'REF actual=%s' % d.get('actual')
        else:
            pay = gk.upper()
        fam[(sec, sk, tail)] += 1
        gk_by[(sec, sk, tail)][pay] += 1
        rows.append((sec, sk, tail, nm, pay, inst, site, path))
print('== GENVAR READS (ours = ref_obj), %d cells ==' % sum(fam.values()))
for key, c in fam.most_common(40):
    sec, sk, tail = key
    for pay, n in gk_by[key].most_common(6):
        print('%7d  %-5s %-4s %-14s  golden: %s' % (n, sec, sk, tail, pay))
if ROWS:
    print('== ROWS ==')
    for r in sorted(set(rows)):
        print(' | '.join(r))
