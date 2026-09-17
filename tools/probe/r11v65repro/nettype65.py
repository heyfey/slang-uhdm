#!/usr/bin/env python3
# v11u65 verifier: per-net vpiNetType lister from a uhdm-dump.
# Skips vpiParent BACKLINK subtrees (the dump reprints the parent inline).
import re, sys
def parse(path):
    with open(path, errors='replace') as f:
        lines = f.read().split('\n')
    sect = {}
    for i, l in enumerate(lines):
        m = re.match(r'^\|uhdm(all|top)(\w+):', l)
        if m:
            sect[i] = ('DEF' if m.group(1) == 'all' else 'ELAB') + ':' + m.group(2)
    cur = '?'; rows = []; scopestack = []; skip_below = None
    prev = ''
    for i, l in enumerate(lines):
        if i in sect:
            cur = sect[i]
        m = re.match(r'^(\s*)([|\\])', l)
        if not m:
            prev = l.strip() if l.strip() else prev
            continue
        ind = len(m.group(1))
        if skip_below is not None:
            if ind > skip_below:
                prev = l.strip(); continue
            skip_below = None
        mn = re.match(r'^(\s*)\\_(\w+): (?:\(([^)]*)\))?', l)
        if mn:
            kind, nm = mn.group(2), mn.group(3) or ''
            if prev == '|vpiParent:':
                skip_below = ind; prev = l.strip(); continue
            while scopestack and scopestack[-1][0] >= ind:
                scopestack.pop()
            if kind.endswith('_net'):
                nt = 0; j = i + 1; fld = ind + 2
                while j < len(lines):
                    m2 = re.match(r'^(\s*)([|\\])', lines[j])
                    if not m2 or len(m2.group(1)) < fld: break
                    if len(m2.group(1)) == fld and lines[j].lstrip().startswith('|vpiNetType:'):
                        nt = int(lines[j].split(':')[1])
                    j += 1
                sc = scopestack[-1][2] if scopestack else ''
                rows.append((cur, sc, nm, kind, nt))
            if kind in ('module_inst','interface_inst','package','gen_scope',
                        'gen_scope_array','named_begin','design','modport'):
                scopestack.append((ind, kind, nm))
        prev = l.strip()
    return rows
for p in sys.argv[1:]:
    for r in parse(p):
        print('%s|%s|%s|%s|NT=%d' % r)
