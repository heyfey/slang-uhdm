#!/usr/bin/env python3
"""r10vbuvm28 VIEW-GENERAL three-way scorer — MEASUREMENT ONLY, LHS always golden.

Payload per object: (kind, VpiName, vpiDecompile, vpiValue, #Path_elems,
path-elem kinds+names).  Keyed on (line, startcol, endcol) so it is view-general
(DEF and ELAB dumps both key the same way) and MULTISET (a Counter, never a
last-writer dict — two objects can share a span).

usage: vscore28.py <G.dump> <PRI.dump> <PAT.dump>
"""
import re, sys, collections

HDR = re.compile(r'\\_(\w+):\s*(?:\(([^)]*)\))?\s*, line:(\d+):(\d+), endln:(\d+):(\d+)')
ATTR = re.compile(r'\s*\|(vpiDecompile|vpiValue|vpiName|vpiOpType|vpiConstType|vpiSize):(\S*)')

def load(path):
    lines = open(path, errors='replace').read().split('\n')
    out = collections.defaultdict(collections.Counter)
    # index of header lines with their indent, so Path_elems can be counted
    for i, l in enumerate(lines):
        m = HDR.search(l)
        if not m:
            continue
        kind, nm = m.group(1), m.group(2) or ''
        ln, c1, c2 = int(m.group(3)), int(m.group(4)), int(m.group(6))
        ind = len(l) - len(l.lstrip())
        fields = {}
        pelems = []
        j = i + 1
        inpath = False
        while j < len(lines):
            lj = lines[j]
            if not lj.strip():
                j += 1; continue
            ij = len(lj) - len(lj.lstrip())
            if ij <= ind:
                break
            a = ATTR.match(lj)
            if a and ij == ind + 2:
                fields.setdefault(a.group(1), a.group(2))
            if ij == ind + 2 and 'vpiPath_elems' in lj:
                inpath = True
            elif ij <= ind + 2 and inpath and 'vpiPath_elems' not in lj:
                inpath = False
            if inpath:
                pm = HDR.search(lj)
                if pm and ij >= ind + 3:
                    pelems.append((pm.group(1), pm.group(2) or ''))
            j += 1
        payload = (kind, nm,
                   fields.get('vpiDecompile', ''), fields.get('vpiValue', ''),
                   fields.get('vpiOpType', ''), len(pelems), tuple(pelems))
        out[(ln, c1, c2)][payload] += 1
    return out

def main():
    G, P, Q = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
    tot = collections.Counter()
    for k in sorted(set(G) | set(P) | set(Q)):
        g, p, q = G.get(k, collections.Counter()), P.get(k, collections.Counter()), Q.get(k, collections.Counter())
        if p == g and q == g:
            tot['ALREADY-OK'] += 1
        elif p != g and q == g:
            tot['FIXED'] += 1
            print('FIXED         %d:%d-%d\n    G=%s\n    P=%s' % (k + (sorted(g.items()), sorted(p.items()))))
        elif p == g and q != g:
            tot['BROKE'] += 1
            print('BROKE         %d:%d-%d\n    G=%s\n    Q=%s' % (k + (sorted(g.items()), sorted(q.items()))))
        else:
            tot['STILL'] += 1
            if p != q:
                tot['STILL-CHANGED'] += 1
                print('STILL-CHANGED %d:%d-%d\n    G=%s\n    P=%s\n    Q=%s' % (k + (sorted(g.items()), sorted(p.items()), sorted(q.items()))))
    print('== ' + '  '.join('%s %d' % (k, tot[k]) for k in
          ('ALREADY-OK', 'FIXED', 'BROKE', 'STILL', 'STILL-CHANGED')))
main()
