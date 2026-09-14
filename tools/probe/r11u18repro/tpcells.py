#!/usr/bin/env python3
"""tpcells.py <dump> — list every type_parameter OBJECT in a uhdm-dump with the
section it appears in and whether it carries vpiLocalParam:1.
uhdm-dump ABBREVIATES a repeat visit (prints the header line with no children),
so an abbreviated line is NOT a second object and is reported as `(ref)`."""
import sys, re
SEC = re.compile(r'^\|uhdm(allPackages|topPackages|allModules|topModules|allClasses|topModules)|^\\_weaklyReferenced')
def indent(l):
    return len(l) - len(l.lstrip(' '))
for path in sys.argv[1:]:
    lines = open(path).read().split('\n')
    sec = 'HEAD'
    print('####', path)
    for i, l in enumerate(lines):
        s = l.strip()
        if s.startswith('|uhdm'):
            sec = s.strip('|:')
        if s.startswith('\\_weaklyReferenced'):
            sec = 'weaklyReferenced'
        m = re.match(r'^(\s*)\\_(type_parameter|parameter): \(([^)]*)\)(.*)$', l)
        if not m:
            continue
        ind = len(m.group(1))
        kind, name, tail = m.group(2), m.group(3), m.group(4)
        # collect this object's own property lines (deeper indent, '|' prefixed)
        props = []
        j = i + 1
        while j < len(lines):
            nl = lines[j]
            if not nl.strip():
                break
            if indent(nl) <= ind and nl.strip().startswith(('\\_', '|')):
                break
            if indent(nl) == ind + 2 and nl.strip().startswith('|'):
                props.append(nl.strip())
            j += 1
        if not props:
            print(f'  {sec:16s} {kind:15s} {name:42s} (ref){tail}')
            continue
        lp = any(p.startswith('|vpiLocalParam') for p in props)
        print(f'  {sec:16s} {kind:15s} {name:42s} local={int(lp)}{tail}')
