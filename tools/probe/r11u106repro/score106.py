#!/usr/bin/env python3
"""r11u106 cell scorer — the NAME key.  A cell is one range bound reached by
tw106.py's walker: key = the name path (container / home names / member names /
range index; every span stripped from the path) + the side (L|R); the value is the bound's JUDGE fields (kind,
value, size, const type, decompile, operand kinds) with the location dropped
(a location-less golden constant is invisible to a location-keyed scorer; the
name key reads it).  Multiset-safe: a key that repeats is compared as the
sorted list of its values.
usage: score106.py <g.tw> <pristine.tw> <law.tw>   -> per moved cell + a TOTAL line
       (swap the last two for the swap control)"""
import collections, re, sys

def load(p):
    d = collections.defaultdict(list)
    for l in open(p):
        l = l.rstrip('\n')
        if not l or '\t' not in l:
            continue
        path, side, val = l.split('\t', 2)
        val = re.sub(r'\s*@\S*\s*$', '', val)
        path = re.sub(r'@(\d+:\d+|-)', '', path)   # spans are not judge fields
        d[path + '\t' + side].append(val)
    return {k: sorted(v) for k, v in d.items()}

G, P, L = (load(x) for x in sys.argv[1:4])
# the NAME-FREE fallback key: a typespec's own name stripped (a pre-existing
# typespec NAME difference — `named_t` vs `it_t` — must not hide the cell)
def nf(k):
    return re.sub(r'_typespec\([^)]*\)', '_typespec', k)
GN = collections.defaultdict(list)
for k, v in G.items():
    GN[nf(k)] += v
to = away = mw = same = nog = 0
for k in sorted(set(P) | set(L)):
    p, l, g = P.get(k), L.get(k), G.get(k)
    if p == l:
        same += 1
        continue
    if g is None and nf(k) in GN:
        g = sorted(GN[nf(k)])
        if l and len(g) != len(l) and len(set(g)) == 1:   # identical golden twins
            g = [g[0]] * len(l)
    if g is None:
        cls = 'NOGOLD'; nog += 1   # golden has no such object at all (pre-existing)
    elif l == g:
        cls = 'TO'; to += 1
    elif p == g:
        cls = 'AWAY'; away += 1
    else:
        cls = 'MWRONG'; mw += 1
    print('%s\t%s\tgold=%s\tpris=%s\tlaw=%s' % (cls, k.replace('\t', ' '), g, p, l))
print('TOTAL TO=%d AWAY=%d MWRONG=%d NOGOLD=%d UNMOVED=%d' % (to, away, mw, nog, same))
