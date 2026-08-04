#!/usr/bin/env python3
"""site.py <dump> [lineRegex]
Projects a uhdm-dump onto one line per LEAF object occurrence that sits at a
source location matching lineRegex, showing type, name, and the cmp-relevant
scalars (decompile/size/constType).  Duplicate (loc,type,name,fields) tuples are
counted, not repeated -- so def-vs-top duplication shows as xN.
"""
import re, sys, collections

pat = re.compile(r'^(\s*)\\_(\w+): ?(\([^)]*\))?, ?(?:id:\d+, )?(?:file:[^,]*, )?line:(\d+):(\d+)')
fld = re.compile(r'^\s*\|(vpiDecompile|vpiSize|vpiConstType|vpiName|vpiFullName|UINT|INT|HEX|BIN|OCT|STRING):(.*)$')

def run(p, lre):
    cur = None
    acc = collections.OrderedDict()
    for ln in open(p):
        m = pat.match(ln)
        if m:
            ind, ty, nm, l, c = m.group(1), m.group(2), m.group(3) or '', m.group(4), m.group(5)
            cur = None
            if re.search(lre, l+':'+c):
                cur = [l+':'+c, ty, nm, []]
                acc.setdefault(tuple(), None)
            continue
        m2 = fld.match(ln)
        if m2 and cur is not None:
            cur[3].append(m2.group(1)+'='+m2.group(2).rstrip())
            k = (cur[0], cur[1], cur[2], tuple(cur[3]))
            acc[k] = acc.get(k, 0)
            # store latest
    return acc

def collect(p, lre):
    out = collections.Counter()
    cur = None
    for ln in open(p):
        m = pat.match(ln)
        if m:
            if cur: out[(cur[0], cur[1], cur[2], tuple(cur[3]))] += 1
            ty, nm, l, c = m.group(2), m.group(3) or '', m.group(4), m.group(5)
            cur = [l+':'+c, ty, nm, []] if re.search(lre, l+':'+c) else None
            continue
        m2 = fld.match(ln)
        if m2 and cur is not None:
            cur[3].append(m2.group(1)+'='+m2.group(2).rstrip())
    if cur: out[(cur[0], cur[1], cur[2], tuple(cur[3]))] += 1
    return out

lre = sys.argv[2] if len(sys.argv) > 2 else r'.'
for p in sys.argv[1:2]:
    pass
a = collect(sys.argv[1], lre)
for k in sorted(a, key=lambda k: (int(k[0].split(':')[0]), int(k[0].split(':')[1]), k[1], k[2])):
    print('  x%-2d %-8s %-14s %-24s %s' % (a[k], k[0], k[1], k[2], ' '.join(k[3])))
