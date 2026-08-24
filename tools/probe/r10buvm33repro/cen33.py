#!/usr/bin/env python3
"""r10buvm33repro/cen33.py — the SYMMETRIC MULTISET join of a sweepcen33 TSV.
MEASUREMENT ONLY.

FEHDR rows are keyed on (test, mode, foreach_stmt span, home) — NOT on the
array reference's name, because the name is exactly what the two producers
disagree about, and a name in the key would hide every disagreement as a
MISSING/EXTRA pair.  SDREF rows are keyed on (test, mode, span, name, home).

Both are MULTISET joins (a last-writer dict drops rows whose keys collide —
RESUME §9), and a key present on only one side is COUNTED, never dropped.

  usage: cen33.py <tsv> [--only-disagree] [--fehdr|--sdref] [--filter SUBSTR]
"""
import sys, collections

path = sys.argv[1]
only  = '--only-disagree' in sys.argv
fam   = 'FEHDR' if '--fehdr' in sys.argv else ('SDREF' if '--sdref' in sys.argv else None)
filt  = None
if '--filter' in sys.argv:
    filt = sys.argv[sys.argv.index('--filter') + 1]

G = collections.defaultdict(list)
O = collections.defaultdict(list)
for ln in open(path, errors='replace'):
    f = ln.rstrip('\n').split('\t')
    if len(f) < 4 or '|' not in f[0]:
        continue
    side, test, mode = f[0].split('|')
    if fam and f[1] != fam:
        continue
    if filt and filt not in test:
        continue
    if f[1] == 'FEHDR':
        key = (test, mode, f[2], [x for x in f if x.startswith('home=')][0])
        pay = (f[3], f[4], [x for x in f if x.startswith('vspan=')][0],
               [x for x in f if x.startswith('ts=')][0],
               [x for x in f if x.startswith('reach=')][0])
    else:
        key = (test, mode, f[2], f[4],
               [x for x in f if x.startswith('home=')][0])
        pay = (f[3], [x for x in f if x.startswith('ts=')][0],
               [x for x in f if x.startswith('pos=')][0],
               [x for x in f if x.startswith('reach=')][0])
    (G if side == 'G' else O)[key].append(pay)

ident = miss = extra = diff = 0
rows = []
for key in sorted(set(list(G) + list(O))):
    g = collections.Counter(G.get(key, []))
    o = collections.Counter(O.get(key, []))
    for p in list((g - o).elements()):
        rows.append(('G-ONLY', key, p))
    for p in list((o - g).elements()):
        rows.append(('O-ONLY', key, p))
    common = sum((g & o).values())
    ident += common
    gonly = sum((g - o).values()); oonly = sum((o - g).values())
    if gonly and oonly: diff += min(gonly, oonly)
    if gonly > oonly:   miss  += gonly - oonly
    if oonly > gonly:   extra += oonly - gonly

for tagr, key, pay in rows:
    if only and tagr not in ('G-ONLY', 'O-ONLY'):
        continue
    print('%-7s %s  ::  %s' % (tagr, ' | '.join(key), ' | '.join(pay)))
print('-- IDENTICAL %d  PAIRED-DISAGREE %d  MISSING-OURS %d  EXTRA-OURS %d'
      % (ident, diff, miss, extra))
