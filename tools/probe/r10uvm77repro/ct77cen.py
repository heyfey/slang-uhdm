#!/usr/bin/env python3
"""r10uvm77 — design-wide HIER_PATH TRAILING-ELEMENT census, both sides,
span-keyed.

THE POPULATION this pass owns is the LAST path element of a dotted
`hier_path`: golden makes it a scoped `ref_obj` when the method was written
WITHOUT parentheses and a `method_func_call` when it was written with them.

Key is `(hier_path decompile name, hier_path START line:col)`.  The START and
not the whole span, because a span carrying the END column would never join the
two sides in the cases where the two sides disagree about the end — a key that
cannot join reads green while measuring nothing (r10uvm74's lesson).

Value is a MULTISET of `CLASS|fullname` for the trailing element, because
Surelog prints an out-of-body method body TWICE (package listing + module HOIST
copy) and collapsing the two would hide half of what this law touches.

A key present on only one side prints ABSENT and COUNTS as a disagreement.

  usage: ct77cen.py <golden.dump> <ours.dump> [name-substring-filter]
         LHS is ALWAYS golden; RHS is ALWAYS ours.
"""
import re, sys, collections

HDR = re.compile(r'^(\s*)\\_(\w+): \(([^)]*)\)(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?')


def scan(path):
    """-> {(hpname, startspan): Counter('CLASS|fullname|span')}, plus the
    per-class tally of every trailing element seen."""
    out = collections.defaultdict(collections.Counter)
    kinds = collections.Counter()
    lines = open(path, errors='replace').read().split('\n')
    n = len(lines)
    for i, ln in enumerate(lines):
        m = HDR.match(ln)
        if not m or m.group(2) != 'hier_path':
            continue
        ind, hpname = m.group(1), m.group(3)
        if not m.group(4):
            continue
        key = (hpname, m.group(4) + ':' + m.group(5))
        childind = len(ind) + 2
        elems = []
        label = None
        j = i + 1
        while j < n:
            s = lines[j]
            if not s.strip():
                break
            cur = len(s) - len(s.lstrip())
            if cur <= len(ind):
                break
            body = s.lstrip()
            if cur == childind and body.startswith('|'):
                label = body
                j += 1
                continue
            if cur == childind and body.startswith('\\_'):
                if label == '|vpiActual:':
                    c = HDR.match(s)
                    if c:
                        sp = (c.group(4) + ':' + c.group(5)) if c.group(4) else '-'
                        elems.append([c.group(2), c.group(3), sp, len(s) - len(s.lstrip())])
                        # the element's own vpiFullName, read at ITS own child
                        # depth only -- never from the subtree below it.
                        k = j + 1
                        fn = ''
                        while k < n:
                            t = lines[k]
                            if not t.strip():
                                break
                            cu = len(t) - len(t.lstrip())
                            if cu <= cur:
                                break
                            if cu == cur + 2 and t.lstrip().startswith('|vpiFullName:'):
                                fn = t.lstrip()[len('|vpiFullName:'):]
                                break
                            k += 1
                        elems[-1][1] = fn or c.group(3)
                j += 1
                continue
            j += 1
        if not elems:
            continue
        t = elems[-1]
        out[key]['%s|%s|%s' % (t[0], t[1], t[2])] += 1
        kinds[t[0]] += 1
    return out, kinds


g, gk = scan(sys.argv[1])
o, ok = scan(sys.argv[2])
pat = sys.argv[3] if len(sys.argv) > 3 else None

print('LHS(golden) hier_path keys: %d   RHS(ours): %d' % (len(g), len(o)))
print('LHS trailing-element classes: %s' % dict(gk))
print('RHS trailing-element classes: %s' % dict(ok))

keys = sorted(set(g) | set(o))
dis = 0
shapes = collections.Counter()
for k in keys:
    a, b = g.get(k), o.get(k)
    if a == b:
        continue
    dis += 1
    ga = 'ABSENT' if a is None else '+'.join('%dx%s' % (v, s) for s, v in sorted(a.items()))
    ob = 'ABSENT' if b is None else '+'.join('%dx%s' % (v, s) for s, v in sorted(b.items()))
    gc = 'ABSENT' if a is None else '+'.join(sorted({s.split('|')[0] for s in a}))
    oc = 'ABSENT' if b is None else '+'.join(sorted({s.split('|')[0] for s in b}))
    shapes[(gc, oc)] += 1
    if pat is None or pat in k[0] or pat in ga or pat in ob:
        print('DIS %-46s @%-12s  G=%s  O=%s' % (k[0][:46], k[1], ga, ob))
print('-- keys=%d disagreeing=%d' % (len(keys), dis))
print('-- disagreement SHAPES (golden-class -> ours-class):')
for (gc, oc), v in shapes.most_common():
    print('   %6d  %-24s -> %s' % (v, gc, oc))
