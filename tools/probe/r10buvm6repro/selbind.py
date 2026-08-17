#!/usr/bin/env python3
"""For each `ref_obj` that is the LHS of a whole-write, print the vpiActual KIND.
usage: selbind.py <dump> ; prints  line:col -> actual kind
"""
import re, sys
lines = open(sys.argv[1]).read().split('\n')
out = []
for i, l in enumerate(lines):
    m = re.match(r'(\s*)\\_ref_obj: \(([^)]*)\), line:(\d+):(\d+)', l)
    if not m: continue
    ind = len(m.group(1))
    act = None
    for j in range(i+1, min(len(lines), i+40)):
        s = lines[j]
        cur = len(s) - len(s.lstrip())
        if s.strip() and cur <= ind: break
        if s.strip() == '|vpiActual:':
            am = re.match(r'\\_(\w+):', lines[j+1].strip())
            act = am.group(1) if am else '?'
            break
    out.append('%s:%s %s -> %s' % (m.group(3), m.group(4), m.group(2), act))
for o in sorted(set(out), key=lambda x: (int(x.split(':')[0]), x)):
    print(o)
