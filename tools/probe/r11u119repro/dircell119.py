#!/usr/bin/env python3
"""Per-OBJECT-KEY direction: rows are keyed by type(name) + parent chain (the
parent chain's own line.col kept); each key's multiset of <file span value>
cells is compared to golden's.  WORSE = keys whose symmetric difference to
golden GREW from pristine to law; BETTER = keys whose difference shrank.
  dircell119.py <golden.uhdm> <pristine.uhdm> <law.uhdm>"""
import collections, os, re, subprocess, sys
LD = os.environ.get('LOCDUMP', '/tmp/r11u119_scr/locdump')
rx = re.compile(r'^(\S+) (\S+) (\S+)( val=\S*)?(.*)$')
def load(p):
    d = collections.defaultdict(collections.Counter)
    for l in subprocess.run([LD, p, '--val'], capture_output=True, text=True).stdout.splitlines():
        m = rx.match(l)
        if m:
            d[(m.group(1), m.group(5))][(m.group(2), m.group(3), m.group(4) or '')] += 1
    return d
G, P, L = (load(x) for x in sys.argv[1:4])
better = worse = 0
wk = []
for k in set(P) | set(L):
    g = G.get(k, collections.Counter())
    dp = sum(((P.get(k, collections.Counter()) - g) + (g - P.get(k, collections.Counter()))).values())
    dl = sum(((L.get(k, collections.Counter()) - g) + (g - L.get(k, collections.Counter()))).values())
    if dl < dp: better += 1
    elif dl > dp: worse += 1; wk.append(k)
print('BETTER=%d WORSE=%d' % (better, worse))
for k in wk[:10]:
    print('  WORSE', k[0], k[1][:120])
