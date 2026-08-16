#!/usr/bin/env python3
"""r10uvm76 — design-wide REF-ACTUAL census, both sides, span-keyed.

For every `ref_obj` printed in a uhdm-dump, record its vpiActual (kind+name),
keyed by (vpiFullName-or-decompile-name, span).  A name is printed TWICE by
Surelog when a method body appears in two views (the package listing and the
module HOIST copy), so the value is a MULTISET of actuals, never a single one —
collapsing it would hide the exact half of the law this pass is about.

A key present on only one side prints ABSENT and COUNTS as a disagreement:
a one-sided key is a real difference, not a missing measurement.
"""
import re, sys, collections

REF = re.compile(r'^(\s*)\\_ref_obj: \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)')
ACT = re.compile(r'^(\s*)\\_(\w+): \(([^)]*)\)')


def scan(path):
    """-> {(name, span): Counter(actual-descriptions)}"""
    out = collections.defaultdict(collections.Counter)
    lines = open(path, errors='replace').read().split('\n')
    n = len(lines)
    for i, ln in enumerate(lines):
        m = REF.match(ln)
        if not m:
            continue
        ind, name, l1, c1 = m.group(1), m.group(2), m.group(3), m.group(4)
        key = (name, l1 + ':' + c1)
        # walk this ref_obj's own property block: strictly deeper indent, and
        # stop at the first line whose indent is <= the ref's own.
        act = 'NONE'
        j = i + 1
        while j < n:
            s = lines[j]
            if not s.strip():
                break
            cur = len(s) - len(s.lstrip())
            if cur <= len(ind) and s.lstrip().startswith('\\_'):
                break
            if s.strip() == '|vpiActual:' and j + 1 < n:
                a = ACT.match(lines[j + 1])
                if a:
                    sp = re.search(r'line:(\d+):(\d+)', lines[j + 1])
                    act = a.group(2) + '(' + a.group(3) + ')' + \
                        ('@' + sp.group(1) + ':' + sp.group(2) if sp else '')
                else:
                    act = 'ACTUAL-UNPARSED'
                break
            j += 1
        out[key][act] += 1
    return out


g = scan(sys.argv[1])
o = scan(sys.argv[2])
pat = sys.argv[3] if len(sys.argv) > 3 else None

keys = sorted(set(g) | set(o))
if pat:
    keys = [k for k in keys if re.search(pat, k[0])]
dis = 0
print("keys=%d (golden-only=%d ours-only=%d)" % (
    len(keys),
    len([k for k in keys if k not in o]), len([k for k in keys if k not in g])))
for k in keys:
    gv = g.get(k)
    ov = o.get(k)
    gs = 'ABSENT' if gv is None else ' + '.join(
        '%dx%s' % (c, a) for a, c in sorted(gv.items()))
    os_ = 'ABSENT' if ov is None else ' + '.join(
        '%dx%s' % (c, a) for a, c in sorted(ov.items()))
    if gs != os_:
        dis += 1
        print("DIFF %-70s @%-12s\n   G: %s\n   O: %s" % (k[0][-70:], k[1], gs, os_))
    elif pat:
        print("SAME %-70s @%-12s  %s" % (k[0][-70:], k[1], gs))
print("-- keys=%d disagreeing=%d" % (len(keys), dis))
