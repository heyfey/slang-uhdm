#!/usr/bin/env python3
"""r10uvm77 — THE ARM CELL TABLE.

A CELL is ONE SOURCE SITE: the METHOD TOKEN's `line:col`, never a dump line,
because an object is not a dump occurrence — the same object prints at several
depths and counting occurrences would weight a cell by how deep it happens to
sit.  For each cell it prints the trailing hier_path element on BOTH sides at
OWN CHILD DEPTH (class + vpiFullName), and a verdict:

  EQ          both sides identical (class AND fullname)
  DIFFER      same CLASS, a field differs
  DIFFERKIND  the two sides emit a DIFFERENT CLASS  <- the cell this law owns
  UNMEASURED  one side emits nothing at this site

  usage: ct77cells.py <golden.dump> <ours.dump>
         LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
"""
import re, sys, collections

HDR = re.compile(r'^(\s*)\\_(\w+): \(([^)]*)\)'
                 r'(?:, line:(\d+):(\d+), endln:(\d+):(\d+))?')


def scan(path):
    """-> {method-token span: (class, fullname, hier_path name)}"""
    out = {}
    lines = open(path, errors='replace').read().split('\n')
    n = len(lines)
    for i, ln in enumerate(lines):
        m = HDR.match(ln)
        if not m or m.group(2) != 'hier_path' or not m.group(4):
            continue
        ind, hpname = m.group(1), m.group(3)
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
            elif cur == childind and body.startswith('\\_') and label == '|vpiActual:':
                c = HDR.match(s)
                if c and c.group(4):
                    fn = c.group(3)
                    k = j + 1
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
                    elems.append((c.group(2), fn,
                                  c.group(4) + ':' + c.group(5)))
            j += 1
        if elems:
            cls, fn, sp = elems[-1]
            out[sp] = (cls, fn, hpname)
    return out


g = scan(sys.argv[1])
o = scan(sys.argv[2])
tally = collections.Counter()
print('%-10s %-46s %-34s %-34s %s' % ('SITE', 'HIER_PATH', 'GOLDEN', 'OURS', 'VERDICT'))
for sp in sorted(set(g) | set(o), key=lambda x: [int(v) for v in x.split(':')]):
    a, b = g.get(sp), o.get(sp)
    if a is None or b is None:
        v = 'UNMEASURED'
    elif a[0] != b[0]:
        v = 'DIFFERKIND'
    elif a[1] != b[1]:
        v = 'DIFFER'
    else:
        v = 'EQ'
    tally[v] += 1
    hp = (a or b)[2]
    print('%-10s %-46s %-34s %-34s %s' % (
        sp, hp[:46],
        ('-' if a is None else '%s %s' % (a[0], a[1]))[:34],
        ('-' if b is None else '%s %s' % (b[0], b[1]))[:34], v))
print('-- CELLS %d  EQ %d  DIFFER %d  DIFFERKIND %d  UNMEASURED %d' % (
    sum(tally.values()), tally['EQ'], tally['DIFFER'], tally['DIFFERKIND'],
    tally['UNMEASURED']))
