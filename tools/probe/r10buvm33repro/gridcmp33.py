#!/usr/bin/env python3
"""r10buvm33repro/gridcmp33.py — read one grid arm CELL BY CELL: golden vs the
PRISTINE binary vs the PATCHED one, for every `foreach` HEADER in the file.
MEASUREMENT ONLY.

  gridcmp33.py <golden dump> <pristine dump> <patched dump>

One row per foreach source line, with the array reference's
`<kind>'<VpiName>'@<span>` and its ACTUAL typespec on all three sides, and a
verdict:

  SAME     all three agree
  FIXED    pristine != golden, patched == golden
  RESIDUE  pristine != golden, patched != golden
  BROKEN   pristine == golden, patched != golden   <-- MUST BE 0

The dump's tree is its INDENTATION; a re-visited object prints as a one-line
stub, so each foreach line is recorded from its FIRST full expansion only.
"""
import re, sys

OBJ = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
FLD = re.compile(r'^(\s*)\|(\w+):')


def parse(path):
    out = {}
    lines = open(path, errors='replace').read().split('\n')
    n = len(lines)
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if not m or m.group(2) != 'foreach_stmt':
            continue
        ind = len(m.group(1))
        loc = LOC.search(ln)
        if not loc:
            continue
        key = int(loc.group(1))
        var = ts = None
        invars = False
        vind = None
        j = i + 1
        while j < n:
            l2 = lines[j]
            if not l2.strip():
                j += 1
                continue
            f = FLD.match(l2)
            o = OBJ.match(l2)
            cur = len(f.group(1)) if f else (len(o.group(1)) if o else None)
            if cur is None:
                j += 1
                continue
            if cur <= ind:
                break
            if f and cur == ind + 2:
                invars = (f.group(2) == 'vpiVariables')
                if f.group(2) in ('vpiLoopVars', 'vpiStmt'):
                    if var is not None:
                        break
                    invars = False
            elif o and cur == ind + 2 and invars and var is None:
                lc = LOC.search(l2)
                var = "%s'%s'@%s" % (o.group(2), o.group(3) or '',
                                     ('%s:%s-%s:%s' % lc.groups()) if lc else '-')
                vind = cur
            elif (o and var is not None and ts is None and vind is not None
                  and cur > vind and o.group(2).endswith('typespec')
                  and o.group(2) != 'ref_typespec'):
                lc = LOC.search(l2)
                ts = "%s'%s'@%s" % (o.group(2), o.group(3) or '',
                                    ('%s:%s-%s:%s' % lc.groups()) if lc else '-')
            j += 1
        if var is not None and (key not in out or out[key][0] is None):
            out[key] = (var, ts)
    return out


g, p, q = (parse(a) for a in sys.argv[1:4])
tally = {}
for k in sorted(set(g) | set(p) | set(q)):
    G, P, Q = g.get(k), p.get(k), q.get(k)
    if P == G and Q == G:
        v = 'SAME'
    elif P != G and Q == G:
        v = 'FIXED'
    elif P == G and Q != G:
        v = 'BROKEN'
    else:
        v = 'RESIDUE'
    tally[v] = tally.get(v, 0) + 1
    print('line %-5d %-8s' % (k, v))
    print('    golden   %s   TS=%s' % (G if G is None else G[0], None if G is None else G[1]))
    print('    pristine %s   TS=%s' % (P if P is None else P[0], None if P is None else P[1]))
    print('    patched  %s   TS=%s' % (Q if Q is None else Q[0], None if Q is None else Q[1]))
print('-- ' + '  '.join('%s %d' % (k, tally[k]) for k in sorted(tally)))
