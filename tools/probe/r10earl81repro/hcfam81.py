#!/usr/bin/env python3
"""r10earl81 — one summary line per database: the port-High_conn SELECT cells
classified by (slot, golden's kind -> our kind).  MEASUREMENT ONLY.

A cell is a KEY (chain + select kind + slot + base, span-free, per score81.py);
the counts are ROW-INSTANCES of the multiset difference, so a key both sides
agree on contributes nothing.  `NOKEY` on a side means the key exists only on
the other side (a structural chain difference, not an index-fold difference).
"""
import sys, collections, re

def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p, errors='replace'):
        if not ln.startswith('SEL '):
            continue
        head, _, pay = ln.rstrip('\n').partition(' || ')
        if 'port(' not in head:
            continue
        key = ' '.join(x for x in head.split(' ') if not x.startswith('sp='))
        d[key][pay] += 1
    return d

def kind(p):
    return p.split(' ')[0].replace('K=', '')

G, O = load(sys.argv[1]), load(sys.argv[2])
cnt = collections.Counter()
for k in set(G) | set(O):
    a, b = G.get(k, collections.Counter()), O.get(k, collections.Counter())
    if a == b:
        continue
    oa, ob = a - b, b - a
    m = re.search(r'k=(\S+) s=(\S+)', k)
    slot = (m.group(1) + '-' + m.group(2)) if m else '?'
    gk = '|'.join(sorted({kind(p) for p in oa})) or 'NOKEY'
    ok = '|'.join(sorted({kind(p) for p in ob})) or 'NOKEY'
    tag = f'{slot}_G_{gk}_O_{ok}'.upper().replace('BIT_SELECT-IDX', 'BITSELIDX') \
                                 .replace('CONSTANT', 'CONST').replace('REF_OBJ', 'REF')
    cnt[tag] += sum(oa.values()) + sum(ob.values())
print(';'.join(f'{k}={v}' for k, v in sorted(cnt.items())))
