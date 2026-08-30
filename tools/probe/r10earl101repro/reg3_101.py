#!/usr/bin/env python3
"""r10earl101 -- MEASUREMENT ONLY.  The THREE-WAY census scorer.

  reg3_101.py <golden.rows> <pristine.rows> <patched.rows> [--rows]

Scores the patched side against the pristine one over the SAME fixed universe,
with the GOLDEN side asserted unchanged:

  TO-GOLDEN    rows that MATCH golden after and did not before
  AWAY-GOLDEN  rows that matched golden before and do NOT after
               (a bare name where golden is qualified, or an alias where
                golden has none, lands HERE -- both one-sided sets are scored)
  ADDED / REMOVED   rows our side gained / lost (the law must add and remove
               no object, so both must read 0)
  MOVED-WRONG  rows still unequal after

All three sides are MULTISETS (collections.Counter): a key repeats, and a
last-writer dict would drop rows.  The FILE is stripped from every payload
(our databases carry an empty VpiFile on some objects; no generated Compare
reads VpiFile).
"""
import sys, collections

def load(p):
    m = collections.Counter()
    for ln in open(p):
        if not ln.startswith('SIG\t'):
            continue
        parts = ln.rstrip('\n').split('\t')
        if len(parts) != 8:
            continue
        _, view, okind, ofull, site, sig, path, payload = parts
        bits = payload.split('|')
        if len(bits) == 4 and ':' in bits[3]:
            bits[3] = bits[3].split(':', 1)[1]
        m[((view, okind, ofull, site, sig, path), '|'.join(bits))] += 1
    return m

def bykey(m):
    d = collections.defaultdict(collections.Counter)
    for (k, v), c in m.items():
        d[k][v] += c
    return d

def main():
    G, P, A = (load(a) for a in sys.argv[1:4])
    show = '--rows' in sys.argv
    gk, pk, ak = bykey(G), bykey(P), bykey(A)
    keys = set(gk) | set(pk) | set(ak)
    to_g = away = added = removed = wrong = 0
    rows = []
    for k in sorted(keys):
        g, p, a = gk.get(k, collections.Counter()), pk.get(k, collections.Counter()), ak.get(k, collections.Counter())
        mp = sum((g & p).values())
        ma = sum((g & a).values())
        if ma > mp:
            to_g += ma - mp
            if show: rows.append(('TO-GOLDEN', k, sorted(p.elements()), sorted(a.elements()), sorted(g.elements())))
        elif mp > ma:
            away += mp - ma
            if show: rows.append(('AWAY-GOLDEN', k, sorted(p.elements()), sorted(a.elements()), sorted(g.elements())))
        np_, na = sum(p.values()), sum(a.values())
        if na > np_:
            added += na - np_
            if show: rows.append(('ADDED', k, sorted(p.elements()), sorted(a.elements()), sorted(g.elements())))
        elif np_ > na:
            removed += np_ - na
            if show: rows.append(('REMOVED', k, sorted(p.elements()), sorted(a.elements()), sorted(g.elements())))
        wrong += sum((a - g).values())
    bs_p = sum((G & P).values()); bs_a = sum((G & A).values())
    print(f'BOTH-SAME {bs_p} -> {bs_a}   ONLY-GOLDEN {sum((G-P).values())} -> {sum((G-A).values())}'
          f'   ONLY-OURS {sum((P-G).values())} -> {sum((A-G).values())}')
    print(f'TO-GOLDEN {to_g}  AWAY-GOLDEN {away}  ADDED {added}  REMOVED {removed}  MOVED-WRONG {wrong}')
    for tag, k, p, a, g in rows:
        print(f'  {tag} ' + ' | '.join(k))
        print(f'      golden={g}')
        print(f'      pris  ={p}')
        print(f'      patc  ={a}')

if __name__ == '__main__':
    main()
