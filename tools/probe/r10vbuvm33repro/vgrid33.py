#!/usr/bin/env python3
"""r10vbuvm33 vgrid33.py — VIEW-GENERAL foreach-header comparator.
Every `foreach_stmt` occurrence in a dump is a MULTISET row (never a
last-writer dict keyed on the source line: a package's DEF and ELAB copies
land on the same line and may carry DIFFERENT shapes — buvm19/buvm22's trap).

  vgrid33.py <golden dump> <pristine dump> <patched dump>

Row payload = (line, col, VAR kind, VAR VpiName, VAR span,
               TS kind, TS VpiName, TS span, LOOPVAR kinds+names)
Verdict per DISTINCT payload-key, comparing COUNTS:
  SAME / FIXED / RESIDUE / BROKEN(pristine right, patched wrong) -> must be 0
"""
import re, sys, collections

OBJ = re.compile(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?(.*)$')
NAM = re.compile(r'^(\s*)\|vpiName:(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
FLD = re.compile(r'^(\s*)\|(\w+):')


def vpiname(lines, idx, ind):
    # the object's OWN |vpiName: field (Compare reads VpiName, never VpiFullName;
    # the dump's parenthesised label IS the fullname).
    j = idx + 1
    n = len(lines)
    while j < n:
        l = lines[j]
        if not l.strip():
            j += 1; continue
        m = NAM.match(l)
        if m and len(m.group(1)) == ind + 2:
            return m.group(2)
        f = FLD.match(l); o = OBJ.match(l)
        cur = len(f.group(1)) if f else (len(o.group(1)) if o else None)
        if cur is not None and cur <= ind:
            return ''
        j += 1
    return ''


def parse(path):
    rows = []
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
        fline, fcol = loc.group(1), loc.group(2)
        var = ts = None
        loopv = []
        sect = None
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
                sect = f.group(2)
            elif o and cur == ind + 2:
                lc = LOC.search(l2)
                span = ('%s:%s-%s:%s' % lc.groups()) if lc else '-'
                if sect == 'vpiVariables' and var is None:
                    var = (o.group(2), vpiname(lines, j, cur), span)
                    vind = cur
                elif sect == 'vpiLoopVars':
                    loopv.append((o.group(2), vpiname(lines, j, cur), span))
            elif (o and var is not None and ts is None and vind is not None
                  and cur > vind and sect == 'vpiVariables'
                  and o.group(2).endswith('typespec')
                  and o.group(2) != 'ref_typespec'):
                lc = LOC.search(l2)
                ts = (o.group(2), vpiname(lines, j, cur),
                      ('%s:%s-%s:%s' % lc.groups()) if lc else '-')
            j += 1
        import os
        proj = os.environ.get('PROJ', 'all')
        v = var if var else ('<none>', '', '-')
        t = ts if ts else ('<none>', '', '-')
        if proj == 'var':
            rows.append((int(fline), int(fcol), v, t, ()))
        elif proj == 'loop':
            rows.append((int(fline), int(fcol), ('-', '', '-'), ('-', '', '-'),
                         tuple(loopv)))
        else:
            rows.append((int(fline), int(fcol), v, t, tuple(loopv)))
    return collections.Counter(rows)


def fmt(r):
    return ("fe@%d:%d VAR=%s'%s'@%s TS=%s'%s'@%s LOOP=%s"
            % (r[0], r[1], r[2][0], r[2][1], r[2][2],
               r[3][0], r[3][1], r[3][2],
               ','.join("%s'%s'@%s" % lv for lv in r[4])))


G, P, Q = (parse(a) for a in sys.argv[1:4])
keys = sorted(set(G) | set(P) | set(Q))
tally = collections.Counter()
for k in keys:
    g, p, q = G[k], P[k], Q[k]
    if g == p == q:
        v = 'SAME'
    elif p != g and q == g:
        v = 'FIXED'
    elif p == g and q != g:
        v = 'BROKEN'
    else:
        v = 'RESIDUE'
    tally[v] += 1
    if v != 'SAME':
        print('%-8s g=%d p=%d q=%d  %s' % (v, g, p, q, fmt(k)))
print('-- ' + '  '.join('%s %d' % (k, tally[k]) for k in sorted(tally)))
