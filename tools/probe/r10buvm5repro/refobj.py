#!/usr/bin/env python3
"""r10buvm5 refobj.py -- for every ref_obj header in a uhdm-dump, report (loc, name, actual-kind).

Emits one line per ref_obj OCCURRENCE, sorted, so the two sides can be diffed
directly.  `actual-kind` is `-` when the ref_obj carries no vpiActual at all.

Dump layout: object header `\\_kind: ...` at indent I; its attribute labels
`|vpiRel:` at indent I+2; each attribute's child header also at I+2.
"""
import re
import sys

path = sys.argv[1]
lines = open(path, encoding='utf-8', errors='replace').read().split('\n')

hdr = re.compile(r'^(\s*)\\_(\w+): ?(.*)$')
lbl = re.compile(r'^(\s*)\|(vpi\w+):(.*)$')
loc = re.compile(r'line:(\d+):(\d+)')

out = []
i = 0
n = len(lines)
while i < n:
    m = hdr.match(lines[i])
    if not m or m.group(2) != 'ref_obj':
        i += 1
        continue
    ind = len(m.group(1))
    txt = m.group(3)
    lm = loc.search(txt)
    where = '%s:%s' % (lm.group(1), lm.group(2)) if lm else 'noloc'
    nm = txt.split(')')[0].lstrip('(') if txt.startswith('(') else ''
    # scan this object's attributes (indent ind+2) until indent drops back
    j = i + 1
    act = '-'
    parent = '?'
    while j < n:
        h = hdr.match(lines[j])
        l = lbl.match(lines[j])
        cur = None
        if h:
            cur = len(h.group(1))
        elif l:
            cur = len(l.group(1))
        if cur is None or cur <= ind:
            break
        if l and cur == ind + 2:
            rel = l.group(2)
            nh = hdr.match(lines[j + 1]) if j + 1 < n else None
            if rel == 'vpiActual' and nh:
                act = nh.group(2)
            if rel == 'vpiParent' and nh:
                parent = nh.group(2)
        j += 1
    out.append('%-12s %-8s %-22s %s' % (where, act, parent, nm))
    i += 1

for o in sorted(out):
    print(o)
