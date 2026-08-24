#!/usr/bin/env python3
"""r10uvm121 — ARM census over a uhdm-dump, keyed VIEW + SPAN (purpose-built goldens only; the corpus census is ct121cen + cen121.py).

MEASUREMENT ONLY; the official uhdm-cmp is the judge.  Golden is always the
first argument.  Compare reads no span, but the arms are purpose-built goldens
where span is the only stable cell name (our objects carry an EMPTY VpiFile and
uhdm-dump reaches one object through several paths), so the key is
(view, span) with a MULTISET of (Rhs-kind, Lhs-kind) values.
"""
import re, sys, collections

SECT = re.compile(r'^\|uhdm(\w+):')

def parse(path):
    lines = open(path, errors='replace').read().split('\n')
    rows = []
    view = '?'
    for i, l in enumerate(lines):
        m = SECT.match(l)
        if m:
            view = m.group(1)
    # second pass tracking view
    view = '?'
    i = 0
    while i < len(lines):
        m0 = SECT.match(lines[i])
        if m0:
            view = m0.group(1); i += 1; continue
        m = re.match(r'^(\s*)\\_assignment: , line:(\d+):(\d+), endln:(\d+):(\d+)', lines[i])
        if not m:
            i += 1; continue
        ind = len(m.group(1))
        span = '%s:%s-%s:%s' % (m.group(2), m.group(3), m.group(4), m.group(5))
        j = i + 1; rhs = 'NULL'; lhs = 'NULL'
        while j < len(lines):
            l = lines[j]
            if not l.strip():
                j += 1; continue
            if SECT.match(l): break
            cur = len(l) - len(l.lstrip())
            if cur <= ind: break
            if cur == ind + 2 and l.strip() == '|vpiRhs:':
                rhs = re.sub(r'^\\_', '', lines[j+1].strip()).split(':')[0]
            if cur == ind + 2 and l.strip() == '|vpiLhs:':
                lhs = re.sub(r'^\\_', '', lines[j+1].strip()).split(':')[0]
            j += 1
        rows.append((view, span, rhs + '/' + lhs))
        i = j
    return rows

if __name__ == '__main__':
    g = collections.Counter(parse(sys.argv[1]))
    o = collections.Counter(parse(sys.argv[2]))
    src = open(sys.argv[3]).read().split('\n') if len(sys.argv) > 3 else []
    keys = sorted(set(g) | set(o), key=lambda k: (int(k[1].split(':')[0]), k[0], k[2]))
    same = onlyg = onlyo = 0
    print('%-14s %-14s %-30s %2s %2s | %s' % ('VIEW', 'SPAN', 'Rhs/Lhs', 'G', 'O', 'SOURCE'))
    for k in keys:
        view, span, val = k
        ng, no = g.get(k, 0), o.get(k, 0)
        n = min(ng, no)
        same += n; onlyg += ng - n; onlyo += no - n
        ln = int(span.split(':')[0])
        txt = src[ln-1].strip() if 0 < ln <= len(src) else ''
        flag = '' if ng == no else ('   <<<' )
        print('%-14s %-14s %-30s %2d %2d | %s%s' % (view, span, val, ng, no, txt[:60], flag))
    print('-- SAME=%d ONLY-GOLDEN=%d ONLY-OURS=%d' % (same, onlyg, onlyo))
