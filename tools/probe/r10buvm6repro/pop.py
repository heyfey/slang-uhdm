#!/usr/bin/env python3
"""r10buvm6 pop.py -- population census: EVERY ref_obj in a uhdm-dump whose
vpiFullName names a declared `ref_var`, with the actual it carries (or `-`) and
its parent kind.

This is the whole population the binding law has to explain -- not just the
sites where the two sides already disagree, which is what makes it an
order-blind census rather than a diff.
"""
import re
import sys
import collections

path = sys.argv[1]
lines = open(path, encoding='utf-8', errors='replace').read().split('\n')

hdr = re.compile(r'^(\s*)\\_(\w+): ?(.*)$')
lbl = re.compile(r'^(\s*)\|(vpi\w+):(.*)$')
loc = re.compile(r'line:(\d+):(\d+)')

# pass 1: every declared ref_var, by fullname
refvars = {}
i = 0
n = len(lines)
while i < n:
    m = hdr.match(lines[i])
    if m and m.group(2) == 'ref_var':
        lm = loc.search(m.group(3))
        ind = len(m.group(1))
        j = i + 1
        fn = None
        while j < n:
            h = hdr.match(lines[j])
            l = lbl.match(lines[j])
            cur = len(h.group(1)) if h else (len(l.group(1)) if l else None)
            if cur is None or cur <= ind:
                break
            if l and cur == ind + 2 and l.group(2) == 'vpiFullName':
                fn = l.group(3)
            j += 1
        if fn and lm:
            refvars.setdefault(fn, '%s:%s' % (lm.group(1), lm.group(2)))
    i += 1

# pass 2: every ref_obj naming one of them
rows = []
i = 0
while i < n:
    m = hdr.match(lines[i])
    if not m or m.group(2) != 'ref_obj':
        i += 1
        continue
    ind = len(m.group(1))
    lm = loc.search(m.group(3))
    where = '%s:%s' % (lm.group(1), lm.group(2)) if lm else 'noloc'
    j = i + 1
    act, parent, fn = '-', '?', None
    while j < n:
        h = hdr.match(lines[j])
        l = lbl.match(lines[j])
        cur = len(h.group(1)) if h else (len(l.group(1)) if l else None)
        if cur is None or cur <= ind:
            break
        if l and cur == ind + 2:
            nh = hdr.match(lines[j + 1]) if j + 1 < n else None
            if l.group(2) == 'vpiActual' and nh:
                act = nh.group(2)
            elif l.group(2) == 'vpiParent' and nh:
                parent = nh.group(2)
            elif l.group(2) == 'vpiFullName':
                fn = l.group(3)
        j += 1
    if fn and fn in refvars:
        rows.append((where, act, parent, refvars[fn], fn))
    i += 1

seen = collections.OrderedDict()
for r in sorted(set(rows)):
    print('use@%-12s decl@%-12s actual=%-10s parent=%-20s %s' %
          (r[0], r[3], r[1], r[2], r[4]))
print('ROWS', len(set(rows)), 'REFVARS', len(refvars))
