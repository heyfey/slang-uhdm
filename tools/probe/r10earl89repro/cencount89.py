#!/usr/bin/env python3
"""r10earl89 — the corpus census classifier.

Joins the golden and ours cell files as a MULTISET (RESUME §9: keys collide
and a last-writer dict drops rows), with the payloads DEDUPED per key first
(our databases list a definition cell and an elaborated cell under one owner
name).  The payload carries only judge-visible fields; the span tail is
stripped before anything is compared.

Buckets, and the two ONE-SIDED sets are scored EXPLICITLY:
  BOTH-SAME            the cell agrees field for field
  FAM-TS-MISSING       the ONLY disagreement is a bound leg where GOLDEN
                       carries a typespec and OURS does not      <- the family
  FAM-TS-EXTRA         ...and the opposite: OURS carries one, golden none
                       <- AWAY TODAY, the rows a widening must not add to
  FAM-TS-KIND          both carry one and they DIFFER
  OTHER-DIFF           any other payload disagreement
  ONLY-GOLDEN / ONLY-OURS

  usage: cencount89.py <prefix>.golden <prefix>.ours <out.txt>
"""
import re, sys, collections

TS = re.compile(r'TS=[^}]*')

def load(p):
    d = collections.defaultdict(set)
    for ln in open(p):
        ln = ln.split(' || SPANS:')[0].rstrip()
        m = re.match(r'RG (.*)\|\|(.*)$', ln)
        if not m:
            continue
        db, rest = m.groups()
        m2 = re.match(r'(.*)\|(#\d+) (.*)$', rest)
        if not m2:
            continue
        d[(db, m2.group(1), m2.group(2))].add(m2.group(3))
    return d

def strip_ts(p):
    return TS.sub('TS=*', p)

def tslist(p):
    return TS.findall(p)

def main():
    G, O = load(sys.argv[1]), load(sys.argv[2])
    b = collections.Counter()
    fam = collections.defaultdict(list)
    for k in set(G) | set(O):
        if k not in G:
            b['ONLY-OURS'] += 1; continue
        if k not in O:
            b['ONLY-GOLDEN'] += 1; continue
        g, o = sorted(G[k]), sorted(O[k])
        if g == o:
            b['BOTH-SAME'] += 1; continue
        if len(g) != len(o) or [strip_ts(x) for x in g] != [strip_ts(x) for x in o]:
            b['OTHER-DIFF'] += 1; fam['OTHER-DIFF'].append((k, g, o)); continue
        gt = [t for x in g for t in tslist(x)]
        ot = [t for x in o for t in tslist(x)]
        miss = sum(1 for a, c in zip(gt, ot) if a != 'TS=none' and c == 'TS=none')
        extra = sum(1 for a, c in zip(gt, ot) if a == 'TS=none' and c != 'TS=none')
        kind = sum(1 for a, c in zip(gt, ot)
                   if a != 'TS=none' and c != 'TS=none' and a != c)
        name = ('FAM-TS-MISSING' if miss and not extra and not kind else
                'FAM-TS-EXTRA' if extra and not miss and not kind else
                'FAM-TS-KIND' if kind and not miss and not extra else
                'FAM-TS-MIXED')
        b[name] += 1; fam[name].append((k, g, o))
    out = open(sys.argv[3], 'w')
    for n in ('BOTH-SAME', 'FAM-TS-MISSING', 'FAM-TS-EXTRA', 'FAM-TS-KIND',
              'FAM-TS-MIXED', 'OTHER-DIFF', 'ONLY-GOLDEN', 'ONLY-OURS'):
        print(f'{n:<16} {b[n]}'); out.write(f'{n:<16} {b[n]}\n')
    for n in ('FAM-TS-MISSING', 'FAM-TS-EXTRA', 'FAM-TS-KIND', 'FAM-TS-MIXED'):
        for k, g, o in sorted(fam[n]):
            out.write(f'\n[{n}] {k[0]}  {k[1]} {k[2]}\n  G: {" ;; ".join(g)}\n'
                      f'  O: {" ;; ".join(o)}\n')
    out.close()

main()
